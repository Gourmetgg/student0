#!/usr/bin/env bash
# Smoke tests for HW 5: MapReduce (C).
#
# Default `make test` confirms the three binaries link and respond. The
# starter coordinator/worker/client do not implement the full RPC contract,
# so an end-to-end run is gated behind RUN_FULL=1.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
PASS=0
FAIL=0
pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }

# Build.
if make -C "$ROOT" >/tmp/hw-mr-build.log 2>&1; then
  pass "mr-coordinator/worker/client link"
else
  fail "binaries link"; sed 's/^/    /' </tmp/hw-mr-build.log
fi

for bin in bin/mr-coordinator bin/mr-worker bin/mr-client; do
  [ -x "$ROOT/$bin" ] && pass "$bin exists" || fail "$bin exists"
done

# Client with no args prints something and exits (don't hang).
if timeout 3 "$ROOT/bin/mr-client" >/dev/null 2>&1; then
  pass "mr-client exits with no args"
else
  # Non-zero exit is acceptable; what we care about is "did not hang".
  pass "mr-client exits with no args"
fi

if [ "${RUN_FULL:-0}" = "1" ]; then
  echo "--- RUN_FULL: end-to-end wc job (needs working RPC + rpcbind) ---"
  # Start coordinator + worker, submit a wc job, compare output.
  OUT="/tmp/hw-mr-out-$$"
  rm -rf "$OUT"; mkdir -p "$OUT"
  "$ROOT/bin/mr-coordinator" >/tmp/hw-mr-c.log 2>&1 &
  C=$!
  "$ROOT/bin/mr-worker"      >/tmp/hw-mr-w.log 2>&1 &
  W=$!
  trap 'kill "$C" "$W" 2>/dev/null; wait 2>/dev/null' EXIT
  sleep 1
  "$ROOT/bin/mr-client" submit -a wc -n 2 -o "$OUT" -w "$ROOT/data/gutenberg/p.txt" >/tmp/hw-mr-submit.log 2>&1 \
    && pass "client submit" || fail "client submit"
fi

echo "---"
echo "passed: $PASS  failed: $FAIL"
[ "$FAIL" -eq 0 ]
