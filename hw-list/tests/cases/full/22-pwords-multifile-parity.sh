#!/usr/bin/env bash
# Case: pwords merges counts across files exactly like words (one thread per
# file must update one shared list).
# Handout: Fall 2025 hw-list, docs/pwords — "Each file should be processed in
# a separate thread"; no intermediate materialization.
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR" all
ref="$T_TMP/ref"; got="$T_TMP/pw"
"$HW_DIR/words"  "$(fixture a.txt)" "$(fixture b.txt)" >"$ref" 2>&1
timeout 10 "$HW_DIR/pwords" "$(fixture a.txt)" "$(fixture b.txt)" >"$got" 2>&1 || t_fail "pwords crashed"
assert_same_file "$ref" "$got" "pwords != words on two files"
