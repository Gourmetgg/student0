#!/usr/bin/env bash
# Smoke tests for HW 0: Intro.
#
# Default `make test` runs only what passes on the unmodified starter:
#   - `limits` builds and runs.
#   - `map`    builds and runs and prints recognisable addresses.
#
# Set RUN_FULL=1 to also exercise the `words` program. Those tests assume the
# student has implemented `num_words` and `count_words` in word_count.c and
# fixed the -Werror unused-variable issue in main.c so the `words` binary
# actually links.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
FIXTURES="$HERE/fixtures"
PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }

require() {
  local name="$1"; shift
  if "$@" >/tmp/hw-intro-out 2>&1; then
    pass "$name"
  else
    fail "$name"
    sed 's/^/    /' </tmp/hw-intro-out
  fi
}

# limits: must build and print "stack" / "process" / "file descriptors".
require "limits builds" make -C "$ROOT" limits
out="$("$ROOT/limits")"
echo "$out" | grep -qi "stack"       && pass "limits prints stack"       || fail "limits prints stack"
echo "$out" | grep -qi "process"     && pass "limits prints process"     || fail "limits prints process"
echo "$out" | grep -qi "file"        && pass "limits prints fd info"     || fail "limits prints fd info"

# map: must build and print at least one hex address.
require "map builds" make -C "$ROOT" map
out="$(timeout 5 "$ROOT/map" 2>&1 || true)"
echo "$out" | grep -qE "0x[0-9a-f]+" && pass "map prints addresses"      || fail "map prints addresses"

if [ "${RUN_FULL:-0}" = "1" ]; then
  echo "--- RUN_FULL: words tests ---"
  if make -C "$ROOT/words" executable >/tmp/hw-intro-words.log 2>&1; then
    pass "words builds"
    out="$(./words/words -c "$FIXTURES/basic.txt" 2>&1)"
    echo "$out" | grep -q "6" && pass "words -c basic.txt" || fail "words -c basic.txt: got $out"
    out="$(./words/words -f "$FIXTURES/basic.txt" 2>&1)"
    echo "$out" | grep -qi "hello" && pass "words -f basic.txt" || fail "words -f basic.txt"
  else
    fail "words builds"; sed 's/^/    /' </tmp/hw-intro-words.log
  fi
fi

echo "---"
echo "passed: $PASS  failed: $FAIL"
[ "$FAIL" -eq 0 ]
