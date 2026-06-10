#!/usr/bin/env bash
# Case: a missing input file fails cleanly (no segfault, non-zero exit).
# Handout: Fall 2025 hw-intro, docs/counting-words (Error handling).
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR/words" executable
run -t 5 "$HW_DIR/words/words" "$T_TMP/does-not-exist.txt"
[ "$RUN_STATUS" -ne 0 ] || t_fail "missing file should exit non-zero"
[ "$RUN_STATUS" -lt 128 ] || t_fail "crashed on missing file (signal $((RUN_STATUS - 128)))"
