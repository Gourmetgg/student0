#!/usr/bin/env bash
# Case: `cmd > file` writes stdout to the file (and not to the terminal).
# Handout: Fall 2025 hw-shell, docs/redirection.
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR"
out="$(tmpfile)"
run -t 3 -i "/bin/echo redirected > $out"$'\n' "$HW_DIR/shell"
assert_file_exists "$out"
assert_eq "$(cat "$out")" "redirected" "> should write the file"
