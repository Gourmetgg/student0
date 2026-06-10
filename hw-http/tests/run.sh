#!/usr/bin/env bash
# Smoke tests for HW 3: HTTP Server (C).
#
# Default `make test` confirms each server variant builds and responds to
# `--help` with a usable Usage message. The starter `httpserver` cannot
# actually accept connections — those tests are gated behind RUN_FULL=1.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
PASS=0
FAIL=0
pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }

# Build.
if make -C "$ROOT" all >/tmp/hw-http-build.log 2>&1; then
  pass "all servers build"
else
  fail "all servers build"; sed 's/^/    /' </tmp/hw-http-build.log
fi

# Each variant prints Usage. The binary does not accept --help so we trigger
# the usage path by running with no args; expect non-zero exit, non-empty msg.
for variant in httpserver forkserver threadserver poolserver; do
  out="$(timeout 3 "$ROOT/$variant" 2>&1 || true)"
  echo "$out" | grep -qi "usage" && pass "$variant prints usage" || fail "$variant prints usage"
done

if [ "${RUN_FULL:-0}" = "1" ]; then
  echo "--- RUN_FULL: serving www/ ---"
  PORT=$(( (RANDOM % 1000) + 18000 ))
  "$ROOT/httpserver" --files "$ROOT/www" --port "$PORT" >/tmp/hw-http-srv.log 2>&1 &
  SRV=$!
  trap 'kill "$SRV" 2>/dev/null; wait 2>/dev/null' EXIT
  sleep 1
  if curl -sf --max-time 5 --noproxy '*' "http://127.0.0.1:$PORT/" -o /tmp/hw-http-body.html; then
    pass "GET / returns 200"
    grep -qi "cs 162" /tmp/hw-http-body.html && pass "body contains 'CS 162'" || fail "body content"
  else
    fail "GET / returns 200"
  fi
fi

echo "---"
echo "passed: $PASS  failed: $FAIL"
[ "$FAIL" -eq 0 ]
