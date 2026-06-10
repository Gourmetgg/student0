#!/usr/bin/env bash
# Case: `cargo test --test smoke` — the binary launches and answers --help.
# (tests/smoke.rs; black-box, passes on the pristine starter.)
source "${TESTLIB:?run via tests/run.sh}"
require_cmd cargo
log="$T_TMP/smoke.log"
(cd "$HW_DIR" && timeout 300 cargo test --test smoke) >"$log" 2>&1 \
  || { tail -20 "$log" | sed 's/^/    /'; t_fail "cargo test --test smoke failed"; }
