#!/usr/bin/env bash
# Case: the precompiled reference `words` prints frequency output (no -f flag
# needed in this assignment).
# Handout: Fall 2025 hw-list, Getting started + Skeleton (words.o provided as
# the sanity-check oracle). Reference format: "%8d\t%s".
source "${TESTLIB:?run via tests/run.sh}"
build "$HW_DIR" all
run -t 5 "$HW_DIR/words" "$(fixture a.txt)"
assert_matches "$RUN_OUT" '3[[:space:]]+gamma' "reference words should count gamma 3x in a.txt"
