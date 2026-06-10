#!/usr/bin/env bash
# Case: a failing command does not kill the shell; the next command runs.
# Handout: Fall 2025 hw-shell, docs/program-execution (error handling).
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR"
run -t 3 -i $'definitely-not-a-cmd\n/bin/echo alive\n' "$HW_DIR/shell"
assert_contains "$RUN_OUT" "alive" "shell must survive a failed command"
