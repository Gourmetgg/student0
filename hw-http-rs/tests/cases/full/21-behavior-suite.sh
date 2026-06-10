#!/usr/bin/env bash
# Case: the black-box behavior suite (tests/behavior.rs, #[ignore]d).
# Covers: 200+Content-Length, MIME, 404, directory listing + parent link,
# /stats counts, 10 concurrent clients — all Fall 2025 autograder areas.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd cargo
log="$T_TMP/behavior.log"
(cd "$HW_DIR" && timeout 600 cargo test --test behavior -- --ignored) >"$log" 2>&1 \
  || { grep -E "^test |FAILED|panicked" "$log" | tail -25 | sed 's/^/    /'; \
       t_fail "behavior tests failing (run them one by one while implementing)"; }
