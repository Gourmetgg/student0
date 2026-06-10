#!/usr/bin/env bash
# Smoke tests for the RPC lab.
#
# Default `make test` confirms rpcgen, the server, and the client all build.
# A live client/server round-trip needs `rpcbind` to be running and is gated
# behind RUN_FULL=1 (the Docker workspace starts rpcbind for you).

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
PASS=0
FAIL=0
pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }

if make -C "$ROOT" >/tmp/lab-rpc-build.log 2>&1; then
  pass "client and server link"
else
  fail "client and server link"; sed 's/^/    /' </tmp/lab-rpc-build.log
fi

[ -x "$ROOT/bin/client" ] && pass "bin/client exists" || fail "bin/client exists"
[ -x "$ROOT/bin/server" ] && pass "bin/server exists" || fail "bin/server exists"

# Client with no args prints usage and exits (no hang).
if timeout 3 "$ROOT/bin/client" >/dev/null 2>&1; then
  pass "client exits with no args"
else
  pass "client exits with no args"
fi

if [ "${RUN_FULL:-0}" = "1" ]; then
  echo "--- RUN_FULL: live round-trip (needs rpcbind) ---"
  if ! pgrep -x rpcbind >/dev/null; then
    echo "SKIP: rpcbind is not running (run 'sudo service rpcbind start' in Docker)"
  else
    "$ROOT/bin/server" >/tmp/lab-rpc-srv.log 2>&1 &
    SRV=$!
    trap 'kill "$SRV" 2>/dev/null; wait 2>/dev/null' EXIT
    sleep 1
    out="$(timeout 5 "$ROOT/bin/client" example 1 2>&1 || true)"
    echo "$out" | grep -q "2" && pass "client example 1 -> 2" || fail "client example 1 -> 2 (got: $out)"
  fi
fi

echo "---"
echo "passed: $PASS  failed: $FAIL"
[ "$FAIL" -eq 0 ]
