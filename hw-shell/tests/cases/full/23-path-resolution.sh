#!/usr/bin/env bash
# Case: a bare command name (no slash) is found on $PATH.
# Handout: Fall 2025 hw-shell, docs/path-resolution.
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR"
run -t 3 -i $'echo path-resolved\n' "$HW_DIR/shell"
assert_contains "$RUN_OUT" "path-resolved" "PATH lookup for 'echo' failed"
