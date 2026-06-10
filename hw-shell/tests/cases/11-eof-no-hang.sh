#!/usr/bin/env bash
# Case: EOF on stdin terminates the shell instead of hanging.
# Rationale: the starter REPL must already exit on EOF; any hang here is a
# regression introduced while editing shell.c.
source "${TESTLIB:?run via tests/run.sh}"
build "$HW_DIR"
run -t 3 -i '' "$HW_DIR/shell"
[ "$RUN_STATUS" != 124 ] || t_fail "shell hangs on EOF (timeout)"
