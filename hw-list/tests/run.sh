#!/usr/bin/env bash
# Smoke tests for HW 1: Lists.
#
# Default `make test` runs only what passes on the unmodified starter:
#   - all four executables (pthread, words, lwords, pwords) link.
#   - `pthread N` runs without crashing.
#   - the reference `words` binary produces some output for a small fixture.
#
# Set RUN_FULL=1 to compare lwords and pwords output to the reference words.
# Those assertions will fail until the student has implemented
# word_count_l.c, word_count_p.c, and pwords.c correctly.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
FIX="$HERE/fixtures"
PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }

# Build everything.
if make -C "$ROOT" all >/tmp/hw-list-build.log 2>&1; then
  pass "binaries link"
else
  fail "binaries link"; sed 's/^/    /' </tmp/hw-list-build.log
fi

# pthread N exits 0.
if timeout 5 "$ROOT/pthread" 2 >/dev/null 2>&1; then
  pass "pthread 2 runs"
else
  fail "pthread 2 runs"
fi

# Reference words: count something from a fixture.
out="$(timeout 5 "$ROOT/words" "$FIX/a.txt" 2>&1 || true)"
echo "$out" | grep -q "gamma" && pass "words prints gamma" || fail "words prints gamma (got: $out)"

if [ "${RUN_FULL:-0}" = "1" ]; then
  echo "--- RUN_FULL: parity tests ---"
  ref="$(mktemp)"; lw="$(mktemp)"; pw="$(mktemp)"
  trap 'rm -f "$ref" "$lw" "$pw"' EXIT
  "$ROOT/words"  "$FIX/a.txt" "$FIX/b.txt" >"$ref"
  "$ROOT/lwords" "$FIX/a.txt" "$FIX/b.txt" >"$lw"
  "$ROOT/pwords" "$FIX/a.txt" "$FIX/b.txt" >"$pw"
  diff -u "$ref" "$lw" && pass "lwords == words" || fail "lwords != words"
  diff -u "$ref" "$pw" && pass "pwords == words" || fail "pwords != words"
fi

echo "---"
echo "passed: $PASS  failed: $FAIL"
[ "$FAIL" -eq 0 ]
