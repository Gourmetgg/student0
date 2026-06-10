#!/usr/bin/env bash
# Case: 25 repeated runs of pwords stay identical to words — a single pass
# means nothing for a race.
# Handout: Fall 2025 hw-list, docs/pwords (Synchronization); Handbook,
# "Concurrency: detect what looks correct".
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR" all
ref="$T_TMP/ref"; got="$T_TMP/pw"
"$HW_DIR/words" "$(fixture a.txt)" "$(fixture b.txt)" >"$ref" 2>&1
for i in $(seq 1 25); do
  timeout 10 "$HW_DIR/pwords" "$(fixture a.txt)" "$(fixture b.txt)" >"$got" 2>&1 \
    || t_fail "pwords crashed on iteration $i"
  diff -u "$ref" "$got" >/dev/null || { diff -u "$ref" "$got" | head -10; t_fail "lost update on iteration $i"; }
done
