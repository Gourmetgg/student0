#!/usr/bin/env bash
# Case: with no file arguments, words reads stdin.
# Handout: Fall 2025 hw-intro, docs/counting-words — "./words < words.txt" → 6
# and "printf hi | ./words" → 1.
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR/words" executable
run -t 5 -i "$(cat "$HW_DIR/words/words.txt")" "$HW_DIR/words/words"
assert_eq "$RUN_OUT" "The total number of words is: 6" "stdin redirection"
run -t 5 -i 'hi' "$HW_DIR/words/words"
assert_eq "$RUN_OUT" "The total number of words is: 1" "printf hi | ./words"
