#!/usr/bin/env bash
# Case (TODO): single-letter tokens are not words.
# Handout: Fall 2025 hw-intro, docs/counting-words — "a sequence of contiguous
# alphabetical characters of length greater than one".
source "${TESTLIB:?run via tests/run.sh}"
require_full
t_todo "craft a fixture full of 1-char tokens (a b c x y z ab) and assert the \
total is exactly 1 (only 'ab' counts); add a -f variant showing no 1-char rows."
