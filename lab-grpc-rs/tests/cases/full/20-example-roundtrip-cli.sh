#!/usr/bin/env bash
# Case: the staff-provided Example RPC round-trips via the CLI (works on the
# pristine starter — proves the gRPC plumbing).
# Handout: Fall 2025 lab-grpc-rs, background Usage; server listens on
# 127.0.0.1:10162 (src/lib.rs).
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd cargo
cargo_build "$HW_DIR"
spawn "$HW_DIR/target/debug/server"
wait_tcp 127.0.0.1 10162 10
run -t 10 "$HW_DIR/target/debug/client" example 1
assert_matches "$RUN_OUT" '(^|[^0-9])2([^0-9]|$)' "client example 1 should print 2"
