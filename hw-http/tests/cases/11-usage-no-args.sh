#!/usr/bin/env bash
# Case: each variant prints a Usage message when run without --files/--proxy.
# Handout: Fall 2025 hw-http, docs/background (Usage) — arg parsing is
# starter-provided, so this must already work.
source "${TESTLIB:?run via tests/run.sh}"
build "$HW_DIR" all
for b in httpserver forkserver threadserver poolserver; do
  run -t 3 "$HW_DIR/$b"
  assert_matches "$RUN_OUT$RUN_ERR" '[Uu]sage' "$b should print usage with no args"
done
