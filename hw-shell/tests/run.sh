#!/usr/bin/env bash
# Smoke tests for HW 2: Shell.
#
# Default `make test` confirms the shell builds and starts. It does NOT assert
# the output of `pwd` or `/bin/echo`, because the starter shell prints
# "This shell doesn't know how to run programs." for every input.
#
# Set RUN_FULL=1 once you have implemented program execution, built-ins,
# redirection, and pipes. Those assertions match the official tasks.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
PASS=0
FAIL=0
pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }

# Build.
if make -C "$ROOT" >/tmp/hw-shell-build.log 2>&1; then
  pass "shell builds"
else
  fail "shell builds"; sed 's/^/    /' </tmp/hw-shell-build.log
fi

# Empty input — shell must not hang.
if printf '' | timeout 3 "$ROOT/shell" >/dev/null 2>&1; then
  pass "shell handles EOF"
else
  fail "shell handles EOF"
fi

# A single unknown line — shell must not crash.
if printf 'definitely-not-a-real-command\n' | timeout 3 "$ROOT/shell" >/dev/null 2>&1; then
  pass "shell handles unknown command"
else
  fail "shell handles unknown command"
fi

if [ "${RUN_FULL:-0}" = "1" ]; then
  echo "--- RUN_FULL: behavior tests ---"
  # pwd built-in.
  out="$(printf 'pwd\n' | timeout 3 "$ROOT/shell")"
  [ "$out" = "$PWD" ] && pass "pwd echoes cwd" || fail "pwd echoes cwd (got: $out)"

  # External command.
  out="$(printf '/bin/echo hello cs162\n' | timeout 3 "$ROOT/shell")"
  echo "$out" | grep -q "hello cs162" && pass "external /bin/echo" || fail "external /bin/echo"

  # Output redirection.
  tmp="$(mktemp)"
  printf '/bin/echo redirected > %s\n' "$tmp" | timeout 3 "$ROOT/shell" >/dev/null
  [ "$(cat "$tmp")" = "redirected" ] && pass "stdout redirection" || fail "stdout redirection"
  rm -f "$tmp"

  # Pipe.
  out="$(printf '/bin/echo a b c | /usr/bin/wc -w\n' | timeout 3 "$ROOT/shell")"
  echo "$out" | grep -q "3" && pass "pipe echo|wc" || fail "pipe echo|wc"
fi

echo "---"
echo "passed: $PASS  failed: $FAIL"
[ "$FAIL" -eq 0 ]
