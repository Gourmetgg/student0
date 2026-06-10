#!/usr/bin/env bash
# Case: limits prints the three required lines (values are 0 on the starter;
# the gated case 25 asserts real soft-limit values).
# Handout: Fall 2025 hw-intro, docs/user-limits — output must look like
#   stack size: ...\n process limit: ...\n max file descriptors: ...
# Course env runs it as `i386-exec ./limits`; locally the native build is fine.
source "${TESTLIB:?run via tests/run.sh}"
build "$HW_DIR" limits
if command -v i386-exec >/dev/null 2>&1; then run -t 5 i386-exec "$HW_DIR/limits"
else run -t 5 "$HW_DIR/limits"; fi
assert_contains "$RUN_OUT" "stack size:"
assert_contains "$RUN_OUT" "process limit:"
assert_contains "$RUN_OUT" "max file descriptors:"
