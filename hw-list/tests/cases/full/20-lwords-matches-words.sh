#!/usr/bin/env bash
# Case: lwords output is identical to the reference words (single file).
# Handout: Fall 2025 hw-list, docs/lwords — "lwords should ... exhibit the same
# behavior as frequency mode of words".
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR" all
ref="$T_TMP/ref"; got="$T_TMP/lw"
"$HW_DIR/words"  "$(fixture a.txt)" >"$ref" 2>&1
timeout 10 "$HW_DIR/lwords" "$(fixture a.txt)" >"$got" 2>&1 || t_fail "lwords crashed"
assert_same_file "$ref" "$got" "lwords != words"
