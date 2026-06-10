#!/usr/bin/env bash
# Case: an absolute-path external command runs via fork/exec.
# Handout: Fall 2025 hw-shell, docs/program-execution.
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR"
run -t 3 -i $'/bin/echo hello cs162\n' "$HW_DIR/shell"
assert_contains "$RUN_OUT" "hello cs162"
