#!/usr/bin/env bash
# Case: CLI-level echo / put / get round-trips.
# Handout: Fall 2025 lab-grpc-rs, docs/issuing-rpcs + docs/kv-store.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd cargo
cargo_build "$HW_DIR"
spawn "$HW_DIR/target/debug/server"
wait_tcp 127.0.0.1 10162 10
run -t 10 "$HW_DIR/target/debug/client" echo grpc-echo-check
assert_contains "$RUN_OUT" "grpc-echo-check"
must_run -t 10 "$HW_DIR/target/debug/client" put kk vv-grpc
run -t 10 "$HW_DIR/target/debug/client" get kk
assert_contains "$RUN_OUT" "vv-grpc"
