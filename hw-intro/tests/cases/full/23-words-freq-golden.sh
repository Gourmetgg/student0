#!/usr/bin/env bash
# Case: -f frequency output matches the handout block exactly: count ascending,
# alphabetical tiebreak, "<count> <word>" with a single space.
# Handout: Fall 2025 hw-intro, docs/counting-words (Frequency count).
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR/words" executable
run -t 5 "$HW_DIR/words" -f "$HW_DIR/words/words.txt"
# The starter main.c prints a "The frequencies of each word are:" header
# before fprint_words, so compare only the count lines.
got="$(printf '%s\n' "$RUN_OUT" | grep -E '^[0-9]+ ')"
want='1 abc
1 bbb
1 def
1 zzz
2 aaa'
assert_eq "$got" "$want" "frequency block for the handout fixture"
