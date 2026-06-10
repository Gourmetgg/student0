#!/usr/bin/env bash
# Case: the staff acceptance tests in src/test.rs ("Do not modify") — exactly
# what the autograder checks (Echo + Put + Get = full score).
# Handout: Fall 2025 lab-grpc-rs, docs/kv-store (Autograder note).
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd cargo
cargo_build "$HW_DIR"
spawn "$HW_DIR/target/debug/server"
wait_tcp 127.0.0.1 10162 10
log="$T_TMP/staff.log"
(cd "$HW_DIR" && timeout 600 cargo test --lib -- --test-threads=1) >"$log" 2>&1 \
  || { grep -E "^test |panicked|error" "$log" | tail -20 | sed 's/^/    /'; \
       t_fail "staff tests failing (expected until Echo/Put/Get are implemented)"; }
