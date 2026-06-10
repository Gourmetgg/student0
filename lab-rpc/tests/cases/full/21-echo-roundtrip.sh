#!/usr/bin/env bash
# Case: ECHO round-trips through the server.
# Handout: Fall 2025 lab-rpc, docs/issuing-rpcs — "./client echo test" → test.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_rpcbind
build "$HW_DIR"
spawn "$HW_DIR/bin/server"
sleep 1
run -t 5 "$HW_DIR/bin/client" echo "cs162-echo-check"
assert_contains "$RUN_OUT" "cs162-echo-check" "echo should return the message"
