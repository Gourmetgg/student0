#!/usr/bin/env bash
# Case: `cargo test --test smoke` — CLI binaries respond. NOTE: full
# `cargo test` does NOT compile on the pristine starter: src/tests/mod.rs
# intentionally contains todo!("Pick an input file") for you to fill in
# (that IS the staff test_wc setup). This case sticks to the smoke target.
source "${TESTLIB:?run via tests/run.sh}"
require_cmd cargo
log="$T_TMP/smoke.log"
(cd "$HW_DIR" && timeout 600 cargo test --test smoke) >"$log" 2>&1 \
  || { tail -20 "$log" | sed 's/^/    /'; t_fail "cargo test --test smoke failed"; }
