#!/usr/bin/env bash
# Case: a nonsense command line does not crash the starter shell.
source "${TESTLIB:?run via tests/run.sh}"
build "$HW_DIR"
run -t 3 -i $'definitely-not-a-real-command\n' "$HW_DIR/shell"
[ "$RUN_STATUS" != 124 ] || t_fail "shell hangs on unknown command"
[ "$RUN_STATUS" -lt 128 ] || t_fail "shell crashed (signal $((RUN_STATUS - 128)))"
