#!/usr/bin/env bash
# tests/lib.sh — shared helper library for every assignment's test cases.
#
# A test case is a standalone bash script under <hw>/tests/cases/ that starts
# with:
#
#     source "${TESTLIB:?run via tests/run.sh}"
#
# and then uses the helpers below. Cases are run by tests/runner.sh, which
# exports TESTLIB (this file), HW_DIR (the assignment directory), T_TMP (a
# fresh private temp dir, deleted afterwards unless KEEP_TMP=1) and T_SHARED
# (one temp dir per runner invocation, used for build caching).
#
# Outcome protocol (the case's exit status):
#   0   PASS
#   77  SKIP  — the case cannot run here (missing tool, gated, starter state)
#   78  TODO  — a placeholder you still have to write
#   124 FAIL  — annotated as TIMEOUT by the runner
#   *   FAIL
#
# Write one behavior per case. Arrange / act / assert / cleanup — cleanup is
# automatic for anything registered with cleanup_add or started with spawn.

set -u -o pipefail

# ---------------------------------------------------------------- outcomes --

t_diag() { printf '%s\n' "$*"; }                  # diagnostic line in the log
t_fail() { printf 'FAIL: %s\n' "$*"; exit 1; }
t_skip() { printf 'SKIP: %s\n' "$*"; exit 77; }
t_todo() { printf 'TODO: %s\n' "$*"; exit 78; }

# -------------------------------------------------------------- assertions --

assert_eq() { # assert_eq GOT WANT [LABEL]
  [ "$1" = "$2" ] && return 0
  t_diag "--- got ---";  printf '%s\n' "$1"
  t_diag "--- want ---"; printf '%s\n' "$2"
  t_fail "${3:-values differ}"
}

assert_ne() { # assert_ne GOT NOTWANT [LABEL]
  [ "$1" != "$2" ] || t_fail "${3:-values should differ} (both: $1)"
}

assert_contains() { # assert_contains HAYSTACK NEEDLE [LABEL]
  case "$1" in *"$2"*) return 0 ;; esac
  t_diag "--- output ---"; printf '%s\n' "$1"
  t_fail "${3:-output does not contain '$2'}"
}

assert_matches() { # assert_matches STRING ERE [LABEL]
  printf '%s' "$1" | grep -qE "$2" && return 0
  t_diag "--- output ---"; printf '%s\n' "$1"
  t_fail "${3:-output does not match /$2/}"
}

assert_exit() { # assert_exit WANTCODE CMD ARGS...
  local want="$1"; shift
  local got=0
  "$@" >/dev/null 2>&1 || got=$?
  [ "$got" = "$want" ] || t_fail "exit $got, want $want: $*"
}

assert_file_exists() { [ -e "$1" ] || t_fail "missing file: $1"; }
assert_executable()  { [ -x "$1" ] || t_fail "not executable: $1"; }

assert_same_file() { # assert_same_file EXPECTED ACTUAL [LABEL]
  diff -u "$1" "$2" && return 0
  t_fail "${3:-files differ}: $1 vs $2"
}

# --------------------------------------------------------------- execution --

# run [-t SECS] [-i STDIN] CMD ARGS...
# Runs CMD under `timeout`, capturing RUN_OUT / RUN_ERR / RUN_STATUS.
# Never fails the case by itself — assert on RUN_* afterwards.
run() {
  local _t=10 _stdin='' _have_stdin=0
  while [ $# -gt 0 ]; do
    case "$1" in
      -t) _t="$2"; shift 2 ;;
      -i) _stdin="$2"; _have_stdin=1; shift 2 ;;
      --) shift; break ;;
      *)  break ;;
    esac
  done
  local _out="$T_TMP/.run-out" _err="$T_TMP/.run-err"
  RUN_STATUS=0
  if [ "$_have_stdin" = 1 ]; then
    printf '%s' "$_stdin" | timeout "$_t" "$@" >"$_out" 2>"$_err" || RUN_STATUS=$?
  else
    timeout "$_t" "$@" >"$_out" 2>"$_err" </dev/null || RUN_STATUS=$?
  fi
  RUN_OUT="$(cat "$_out")"
  RUN_ERR="$(cat "$_err")"
}

# must_run [-t SECS] [-i STDIN] CMD...  — run + assert exit status 0.
must_run() {
  run "$@"
  if [ "$RUN_STATUS" != 0 ]; then
    local note=""; [ "$RUN_STATUS" = 124 ] && note=" (TIMEOUT)"
    t_diag "--- stdout ---"; printf '%s\n' "$RUN_OUT"
    t_diag "--- stderr ---"; printf '%s\n' "$RUN_ERR"
    t_fail "command exited $RUN_STATUS$note: $*"
  fi
}

# --------------------------------------------------- processes and cleanup --

_CLEANUP_FILE="${T_TMP:-/tmp}/.cleanup-$$"
cleanup_add() { printf '%s\n' "$*" >>"$_CLEANUP_FILE"; }
_run_cleanups() {
  [ -f "$_CLEANUP_FILE" ] || return 0
  # run registered cleanups in reverse order, ignore their failures
  tac "$_CLEANUP_FILE" 2>/dev/null | while IFS= read -r c; do
    eval "$c" >/dev/null 2>&1 || true
  done
  rm -f "$_CLEANUP_FILE"
}
trap _run_cleanups EXIT

# spawn CMD ARGS...  — start a background process; killed automatically on
# exit. Sets SPAWN_PID and SPAWN_LOG (combined stdout+stderr).
_SPAWN_N=0
spawn() {
  _SPAWN_N=$((_SPAWN_N + 1))
  SPAWN_LOG="$T_TMP/spawn-$_SPAWN_N.log"
  "$@" >"$SPAWN_LOG" 2>&1 &
  SPAWN_PID=$!
  cleanup_add "kill $SPAWN_PID; wait $SPAWN_PID"
}

# wait_tcp HOST PORT [SECS] — poll until something accepts on HOST:PORT.
wait_tcp() {
  local host="$1" port="$2" budget="${3:-5}" i
  for i in $(seq 1 $((budget * 10))); do
    if (exec 3<>"/dev/tcp/$host/$port") 2>/dev/null; then
      exec 3>&- 3<&- 2>/dev/null || true
      return 0
    fi
    sleep 0.1
  done
  t_fail "nothing listening on $host:$port after ${budget}s"
}

# pick_port — print a free-ish TCP port (18000-28999).
pick_port() {
  local p try
  for try in 1 2 3 4 5; do
    p=$(( (RANDOM % 11000) + 18000 ))
    if ! (exec 3<>"/dev/tcp/127.0.0.1/$p") 2>/dev/null; then
      printf '%s\n' "$p"; return 0
    fi
    exec 3>&- 3<&- 2>/dev/null || true
  done
  printf '%s\n' "$p"
}

# ------------------------------------------------------------------ guards --

require_cmd() { # require_cmd NAME...  — SKIP if any tool is missing
  local c
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || t_skip "required tool not installed: $c"
  done
}

require_file() { [ -e "$1" ] || t_skip "required file missing: $1"; }

require_rpcbind() {
  pgrep -x rpcbind >/dev/null 2>&1 \
    || t_skip "rpcbind not running (try: sudo service rpcbind start)"
}

require_qemu() { require_cmd qemu-system-i386; }

# require_full — SKIP unless RUN_FULL=1. The runner already gates cases under
# tests/cases/full/; this guard keeps a case honest when run directly.
require_full() {
  [ "${RUN_FULL:-0}" = "1" ] || t_skip "gated behavior test: set RUN_FULL=1"
}

# ------------------------------------------------------------------- build --

# build DIR [TARGET...] — `make -C DIR TARGET...`, cached per runner
# invocation. FAILs the case (with the log tail) if the build breaks.
build() {
  local dir="$1"; shift || true
  local key stamp log
  key="$(printf '%s|%s' "$dir" "$*" | cksum | tr ' ' '-')"
  stamp="$T_SHARED/build-$key.ok"
  log="$T_SHARED/build-$key.log"
  [ -e "$stamp" ] && return 0
  if [ -e "$stamp.fail" ]; then
    t_fail "build already failed earlier: make -C $dir $* (log: $log)"
  fi
  if make -C "$dir" "$@" >"$log" 2>&1; then
    : >"$stamp"
    return 0
  fi
  : >"$stamp.fail"
  t_diag "--- build log tail: make -C $dir $* ---"
  tail -n 25 "$log" | sed 's/^/    /'
  t_fail "build failed: make -C $dir $*"
}

# try_build DIR [TARGET...] — like build, but returns 1 instead of failing.
# Use it to SKIP honestly when the pristine starter cannot compile.
try_build() {
  local dir="$1"; shift || true
  local key stamp log
  key="$(printf '%s|%s' "$dir" "$*" | cksum | tr ' ' '-')"
  stamp="$T_SHARED/try-$key.ok"
  log="$T_SHARED/try-$key.log"
  [ -e "$stamp" ] && return 0
  [ -e "$stamp.fail" ] && return 1
  if make -C "$dir" "$@" >"$log" 2>&1; then
    : >"$stamp"; return 0
  fi
  : >"$stamp.fail"; TRY_BUILD_LOG="$log"; return 1
}

# cargo_build DIR [ARGS...] — `cargo build` with a captured log. Cargo does
# its own incremental caching, so no sentinel is needed.
cargo_build() {
  local dir="$1"; shift || true
  local log="$T_SHARED/cargo-$(basename "$dir").log"
  if (cd "$dir" && cargo build "$@") >"$log" 2>&1; then
    return 0
  fi
  t_diag "--- cargo build log tail ---"
  tail -n 25 "$log" | sed 's/^/    /'
  t_fail "cargo build failed in $dir"
}

# ------------------------------------------------------------ text helpers --

# golden ACTUAL_FILE GOLDEN_FILE [FILTER_CMD] — diff against a golden file,
# optionally normalizing both sides through FILTER_CMD first.
golden() {
  local actual="$1" expect="$2" filter="${3:-}"
  if [ -n "$filter" ]; then
    local a="$T_TMP/.golden-a" b="$T_TMP/.golden-b"
    $filter <"$actual" >"$a"
    $filter <"$expect" >"$b"
    diff -u "$b" "$a" || t_fail "output differs from golden $expect (normalized)"
  else
    diff -u "$expect" "$actual" || t_fail "output differs from golden $expect"
  fi
}

normalize_ws()    { sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//'; }
strip_hex_addrs() { sed -E 's/0x[0-9a-fA-F]+/0xADDR/g'; }

# -------------------------------------------------------------------- misc --

fixture() { printf '%s\n' "$HW_DIR/tests/fixtures/$1"; }
tmpfile() { mktemp "$T_TMP/t.XXXXXX"; }
