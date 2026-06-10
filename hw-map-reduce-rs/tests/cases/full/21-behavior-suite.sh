#!/usr/bin/env bash
# Case: black-box behavior tests (tests/behavior.rs): e2e wc job + your TODO
# stubs for queue order, crash-rerun, and error propagation.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd cargo
log="$T_TMP/behavior.log"
(cd "$HW_DIR" && timeout 600 cargo test --test behavior -- --ignored --test-threads=1 e2e_) >"$log" 2>&1 \
  || { grep -E "^test |panicked|error" "$log" | tail -25 | sed 's/^/    /'; \
       t_fail "behavior e2e failing (todo_ stubs are excluded by the e2e_ filter)"; }
