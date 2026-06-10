#!/usr/bin/env bash
# Case: the provided pthread demo runs and prints per-thread stack lines.
# Handout: Fall 2025 hw-list, docs/pthread (read-only analysis subject).
source "${TESTLIB:?run via tests/run.sh}"
build "$HW_DIR" all
run -t 5 "$HW_DIR/pthread" 2
[ "$RUN_STATUS" -eq 0 ] || t_fail "pthread 2 exited $RUN_STATUS"
assert_contains "$RUN_OUT" "Main stack:"
assert_matches "$RUN_OUT" 'Thread #[0-9a-fx]+ stack:' "expected per-thread lines"
