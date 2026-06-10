#!/usr/bin/env bash
# Case: built-in `pwd` prints the shell's working directory.
# Handout: Fall 2025 hw-shell, docs/directory-commands.
# The starter prints a placeholder for every command, so this is gated.
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR"
cd "$HW_DIR"
run -t 3 -i $'pwd\n' ./shell
assert_eq "$RUN_OUT" "$HW_DIR" "pwd should echo the cwd"
