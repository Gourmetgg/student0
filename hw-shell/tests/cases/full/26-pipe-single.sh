#!/usr/bin/env bash
# Case: a two-stage pipeline passes bytes between processes.
# Handout: Fall 2025 hw-shell, docs/pipes.
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR"
run -t 3 -i $'/bin/echo a b c | /usr/bin/wc -w\n' "$HW_DIR/shell"
assert_matches "$RUN_OUT" '(^|[^0-9])3([^0-9]|$)' "echo a b c | wc -w should print 3"
