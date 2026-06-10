#!/usr/bin/env bash
# Case: counts accumulate across multiple file arguments.
# Handout: Fall 2025 hw-intro, docs/counting-words — "./words words.txt
# words.txt" must print 12.
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR/words" executable
f="$HW_DIR/words/words.txt"
run -t 5 "$HW_DIR/words/words" "$f" "$f"
assert_eq "$RUN_OUT" "The total number of words is: 12"
