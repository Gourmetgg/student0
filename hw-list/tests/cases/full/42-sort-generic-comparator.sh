#!/usr/bin/env bash
# Case (TODO): wordcount_sort works with ANY comparator, e.g. less_word.
# Handout: Fall 2025 hw-list, docs/lwords — "generic enough to work with any
# valid comparator passed in as the less argument".
source "${TESTLIB:?run via tests/run.sh}"
require_full
t_todo "write a 20-line driver C file in tests/ that links word_count_l.c with \
PINTOS_LIST, builds a list, sorts with less_word, and prints alphabetically; \
compile it in the case and assert the order."
