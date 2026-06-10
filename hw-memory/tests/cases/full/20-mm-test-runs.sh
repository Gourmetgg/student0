#!/usr/bin/env bash
# Case: the handout's own sanity harness runs clean.
# Handout: Fall 2025 hw-memory, docs/library-functions/introduction —
# "The given mm_test.c performs some sanity checks but is not exhaustive."
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR/mm_alloc"
run -t 10 "$HW_DIR/mm_alloc/mm_test"
[ "$RUN_STATUS" -eq 0 ] || { printf '%s\n' "$RUN_OUT" "$RUN_ERR" | sed 's/^/    /'; t_fail "mm_test exited $RUN_STATUS"; }
assert_contains "$RUN_OUT" "malloc test successful" "mm_test success banner"
