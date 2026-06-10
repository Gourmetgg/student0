#!/usr/bin/env bash
# Case: pwords output is identical to the reference words (single file).
# Handout: Fall 2025 hw-list, docs/pwords (Implementation).
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR" all
ref="$T_TMP/ref"; got="$T_TMP/pw"
"$HW_DIR/words"  "$(fixture a.txt)" >"$ref" 2>&1
timeout 10 "$HW_DIR/pwords" "$(fixture a.txt)" >"$got" 2>&1 || t_fail "pwords crashed"
assert_same_file "$ref" "$got" "pwords != words"
