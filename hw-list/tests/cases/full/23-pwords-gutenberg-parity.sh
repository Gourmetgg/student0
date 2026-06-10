#!/usr/bin/env bash
# Case: pwords matches words on the large gutenberg inputs — the handout's own
# recipe for surfacing subtle races.
# Handout: Fall 2025 hw-list, docs/pwords (Synchronization).
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR" all
files="$(ls "$HW_DIR"/gutenberg/*.txt 2>/dev/null | head -4)"
[ -n "$files" ] || t_skip "gutenberg/ inputs not found"
ref="$T_TMP/ref"; got="$T_TMP/pw"
# shellcheck disable=SC2086
"$HW_DIR/words" $files >"$ref" 2>&1
# shellcheck disable=SC2086
timeout 60 "$HW_DIR/pwords" $files >"$got" 2>&1 || t_fail "pwords crashed on gutenberg"
assert_same_file "$ref" "$got" "pwords != words on gutenberg set"
