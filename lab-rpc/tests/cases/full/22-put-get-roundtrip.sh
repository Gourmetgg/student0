#!/usr/bin/env bash
# Case: PUT then GET returns the stored value.
# Handout: Fall 2025 lab-rpc, docs/kv-store.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_rpcbind
build "$HW_DIR"
spawn "$HW_DIR/bin/server"
sleep 1
must_run -t 5 "$HW_DIR/bin/client" put k162 v-systems
run -t 5 "$HW_DIR/bin/client" get k162
assert_contains "$RUN_OUT" "v-systems" "get should return the put value"
