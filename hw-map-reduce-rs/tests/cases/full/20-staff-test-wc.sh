#!/usr/bin/env bash
# Case: the staff end-to-end test (src/tests/mod.rs test_wc). You must first
# replace todo!("Pick an input file") with a real input (e.g.
# "data/gutenberg/p.txt") — the handout treats that as part of setup.
# Handout: Fall 2025 hw-map-reduce-rs, docs/background/development.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd cargo
if grep -q 'todo!("Pick an input file")' "$HW_DIR/src/tests/mod.rs"; then
  t_skip "src/tests/mod.rs still has the todo! placeholder — fill it in first"
fi
log="$T_TMP/test-wc.log"
(cd "$HW_DIR" && timeout 600 cargo test test_wc -- --ignored) >"$log" 2>&1 \
  || { grep -E "^test |panicked|error" "$log" | tail -20 | sed 's/^/    /'; \
       t_fail "staff test_wc failing"; }
