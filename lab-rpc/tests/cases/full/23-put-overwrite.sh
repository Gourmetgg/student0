#!/usr/bin/env bash
# Case: a second PUT for the same key overwrites the value.
# Handout: Fall 2025 lab-rpc, docs/kv-store (hash-map semantics).
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_rpcbind
build "$HW_DIR"
spawn "$HW_DIR/bin/server"
sleep 1
must_run -t 5 "$HW_DIR/bin/client" put dupkey first
must_run -t 5 "$HW_DIR/bin/client" put dupkey second
run -t 5 "$HW_DIR/bin/client" get dupkey
assert_contains "$RUN_OUT" "second" "value should be overwritten"
case "$RUN_OUT" in *first*) t_fail "stale value 'first' still returned";; esac
