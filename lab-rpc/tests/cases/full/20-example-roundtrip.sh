#!/usr/bin/env bash
# Case: the staff-provided EXAMPLE RPC round-trips (works on the pristine
# starter — proves rpcbind + the RPC plumbing before you write any code).
# Handout: Fall 2025 lab-rpc, Usage — "./bin/client example 1" → 2.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_rpcbind
build "$HW_DIR"
spawn "$HW_DIR/bin/server"
sleep 1
run -t 5 "$HW_DIR/bin/client" example 1
assert_matches "$RUN_OUT" '(^|[^0-9])2([^0-9]|$)' "client example 1 should print 2"
