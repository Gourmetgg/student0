#!/usr/bin/env bash
# Case: the handout's own worked redirection example.
# Handout: Fall 2025 hw-shell, docs/redirection ("Testing" section):
#   /usr/bin/wc < test_redirection_in > test_redirection_out
# with input "i love pintos and cs162" must yield roughly " 1  5 24".
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR"
cd "$T_TMP"
printf 'i love pintos and cs162' >test_redirection_in
run -t 5 -i $'/usr/bin/wc < test_redirection_in > test_redirection_out\n' "$HW_DIR/shell"
assert_file_exists test_redirection_out
got="$(normalize_ws <test_redirection_out)"
assert_eq "$got" "0 5 23" "wc < in > out (no trailing newline in fixture: 0 lines, 5 words, 23 chars)"
