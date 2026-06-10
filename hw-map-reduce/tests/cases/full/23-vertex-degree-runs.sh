#!/usr/bin/env bash
# Case: the vertex-degree app completes on the medium graph dataset.
# Mirrors the autograder's `vertex-degree` test.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_rpcbind
build "$HW_DIR"
cd "$HW_DIR"
in="$(ls data/graph-edges-medium/* 2>/dev/null | head -2)"
[ -n "$in" ] || t_skip "graph-edges-medium dataset missing"
spawn ./bin/mr-coordinator
sleep 1
spawn ./bin/mr-worker
spawn ./bin/mr-worker
# shellcheck disable=SC2086
must_run -t 120 ./bin/mr-client submit -a vertex-degree -n 2 -o "$T_TMP/vd" -w $in
run -t 60 ./bin/mr-client process -a vertex-degree -n 2 -o "$T_TMP/vd"
[ "$RUN_STATUS" -eq 0 ] || t_fail "process failed"
[ -n "$RUN_OUT" ] || t_fail "vertex-degree produced no output"
