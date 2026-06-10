#!/usr/bin/env bash
# Case: the staff unit tests in src/tests/ all pass (Parts 1+4 done).
# Handout: Fall 2025 hw-http-rs, docs/stats — names incr_items,
# incr_items_four, items_sorted; http tests cover end_headers/get_mime_type.
# On the pristine starter 6 of 12 fail (todo! panics) — that is the expected
# starting point, not a framework bug.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd cargo
log="$T_TMP/unit.log"
(cd "$HW_DIR" && timeout 600 cargo test --bins) >"$log" 2>&1 \
  || { grep -E "^test |FAILED|panicked" "$log" | tail -20 | sed 's/^/    /'; \
       t_fail "staff unit tests failing (expected until Parts 1 & 4 are done)"; }
