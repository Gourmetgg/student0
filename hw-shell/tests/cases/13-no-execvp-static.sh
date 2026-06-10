#!/usr/bin/env bash
# Case: shell.c must not contain the string `execvp`.
# Handout: Fall 2025 hw-shell, docs/path-resolution — "the autograder looks
# for execvp, and you won't receive a grade if that word is found".
# This mirrors that autograder grep so you find out locally, not at submit time.
source "${TESTLIB:?run via tests/run.sh}"
if grep -n 'execvp' "$HW_DIR/shell.c"; then
  t_fail "shell.c contains 'execvp' — banned by the hw-shell autograder"
fi
