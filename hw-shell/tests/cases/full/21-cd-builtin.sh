#!/usr/bin/env bash
# Case: built-in `cd` changes the *shell's* directory (not a child's).
# Handout: Fall 2025 hw-shell, docs/directory-commands.
# This catches the classic "cd runs in a forked child" bug.
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR"
run -t 3 -i $'cd /\npwd\n' "$HW_DIR/shell"
assert_eq "$RUN_OUT" "/" "cd / then pwd should print /"
