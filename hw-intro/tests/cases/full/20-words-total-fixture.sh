#!/usr/bin/env bash
# Case: total word count on the handout fixture words/words.txt.
# Handout: Fall 2025 hw-intro, docs/counting-words — "./words words.txt" must
# print "The total number of words is: 6" (note: "a" is NOT a word; words are
# alphabetic runs of length > 1, case-insensitive).
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR/words" executable
run -t 5 "$HW_DIR/words/words" "$HW_DIR/words/words.txt"
assert_eq "$RUN_OUT" "The total number of words is: 6"
