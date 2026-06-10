#!/usr/bin/env bash
# Case: `cmd < file` feeds the file to the command's stdin.
# Handout: Fall 2025 hw-shell, docs/redirection.
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR"
in="$(tmpfile)"
printf 'from-a-file\n' >"$in"
run -t 3 -i "/bin/cat < $in"$'\n' "$HW_DIR/shell"
assert_contains "$RUN_OUT" "from-a-file"
