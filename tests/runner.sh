#!/usr/bin/env bash
# tests/runner.sh — discover and run one assignment's test cases.
#
#   bash tests/runner.sh HW_DIR [NAME-GLOB]
#
# Normally invoked through the 3-line wrapper <hw>/tests/run.sh.
#
# Case discovery:
#   <hw>/tests/cases/*.sh        always run
#   <hw>/tests/cases/full/*.sh   run only when RUN_FULL=1; otherwise listed
#                                as GATED so you can see what is waiting
#
# Case outcome protocol (exit status): 0 PASS, 77 SKIP, 78 TODO, 124 FAIL
# (timeout), anything else FAIL. The runner exits non-zero iff some case
# FAILed — SKIP/TODO/GATED never break the run.
#
# Environment:
#   RUN_FULL=1      also run cases/full/ (behavior tests needing your impl)
#   VERBOSE=1       stream case output instead of only showing it on failure
#   KEEP_TMP=1      keep per-case temp dirs for post-mortem
#   CASE_TIMEOUT=N  hard per-case wall-clock limit in seconds (default 300)

set -u -o pipefail

usage() { echo "usage: bash tests/runner.sh HW_DIR [NAME-GLOB]" >&2; exit 2; }
[ $# -ge 1 ] || usage

HW_DIR="$(cd "$1" && pwd)" || usage
GLOB="${2:-}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export TESTLIB="$ROOT/tests/lib.sh"
export HW_DIR

CASE_TIMEOUT="${CASE_TIMEOUT:-300}"
T_SHARED="$(mktemp -d "${TMPDIR:-/tmp}/cs162-$(basename "$HW_DIR").XXXXXX")"
export T_SHARED
cleanup_shared() {
  [ "${KEEP_TMP:-0}" = "1" ] || rm -rf "$T_SHARED"
}
trap cleanup_shared EXIT

pass=0; fail=0; skip=0; todo=0; gated=0

collect() {
  local d="$1"
  [ -d "$d" ] || return 0
  find "$d" -maxdepth 1 -name '*.sh' -type f | sort
}

case_name() { # path -> cases-relative name without .sh
  local p="${1#"$HW_DIR/tests/cases/"}"
  printf '%s\n' "${p%.sh}"
}

first_tagline() { # extract the SKIP:/TODO: reason from captured output
  grep -m1 -E '^(SKIP|TODO):' "$1" 2>/dev/null | cut -d' ' -f2- || true
}

run_case() {
  local case_file="$1" name; name="$(case_name "$case_file")"
  if [ -n "$GLOB" ]; then
    # shellcheck disable=SC2254
    case "$name" in $GLOB) ;; *) return 0 ;; esac
  fi
  local T_TMP out st=0
  T_TMP="$(mktemp -d "$T_SHARED/case-XXXXXX")"
  export T_TMP
  out="$T_TMP/.output"
  if [ "${VERBOSE:-0}" = "1" ]; then
    echo "--- $name ---"
    timeout "$CASE_TIMEOUT" bash "$case_file" 2>&1 | tee "$out"
    st=${PIPESTATUS[0]}
  else
    timeout "$CASE_TIMEOUT" bash "$case_file" >"$out" 2>&1 || st=$?
  fi
  case "$st" in
    0)  echo "PASS  $name"; pass=$((pass + 1)) ;;
    77) echo "SKIP  $name — $(first_tagline "$out")"; skip=$((skip + 1)) ;;
    78) echo "TODO  $name — $(first_tagline "$out")"; todo=$((todo + 1)) ;;
    *)  local note=""; [ "$st" = 124 ] && note=" (TIMEOUT after ${CASE_TIMEOUT}s)"
        echo "FAIL  $name (exit $st)$note"
        sed 's/^/      | /' <"$out"
        fail=$((fail + 1)) ;;
  esac
  [ "${KEEP_TMP:-0}" = "1" ] || rm -rf "$T_TMP"
}

echo "== $(basename "$HW_DIR") =="

while IFS= read -r f; do
  [ -n "$f" ] && run_case "$f"
done <<EOF
$(collect "$HW_DIR/tests/cases")
EOF

if [ "${RUN_FULL:-0}" = "1" ]; then
  while IFS= read -r f; do
    [ -n "$f" ] && run_case "$f"
  done <<EOF
$(collect "$HW_DIR/tests/cases/full")
EOF
else
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    name="$(case_name "$f")"
    if [ -n "$GLOB" ]; then
      # shellcheck disable=SC2254
      case "$name" in $GLOB) ;; *) continue ;; esac
    fi
    echo "GATED $name (set RUN_FULL=1)"
    gated=$((gated + 1))
  done <<EOF
$(collect "$HW_DIR/tests/cases/full")
EOF
fi

echo "-- $(basename "$HW_DIR"): $pass pass, $fail fail, $skip skip, $todo todo, $gated gated"
echo "#totals pass=$pass fail=$fail skip=$skip todo=$todo gated=$gated"
[ "$fail" -eq 0 ]
