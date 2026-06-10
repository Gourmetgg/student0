#!/usr/bin/env bash
# Case: report whether words/ compiles. On the pristine Fall25 starter this
# SKIPs: words/Makefile uses -Wall -Werror and the skeleton trips it until you
# start the assignment. Once you edit main.c/word_count.c it must build.
# Handout: Fall 2025 hw-intro, docs/counting-words.
source "${TESTLIB:?run via tests/run.sh}"
if try_build "$HW_DIR/words" executable; then
  assert_executable "$HW_DIR/words/words"
else
  tail -n 8 "$TRY_BUILD_LOG" | sed 's/^/    /'
  t_skip "words does not compile on the pristine starter (-Werror); expected until implemented"
fi
