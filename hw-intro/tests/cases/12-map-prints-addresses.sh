#!/usr/bin/env bash
# Case: map builds and prints memory addresses (the GDB-walkthrough subject).
# Handout: Fall 2025 hw-intro, docs/gdb ("compile it by running make map";
# course env uses `i386-exec ./map`).
source "${TESTLIB:?run via tests/run.sh}"
build "$HW_DIR" map
if command -v i386-exec >/dev/null 2>&1; then run -t 5 i386-exec "$HW_DIR/map"
else run -t 5 "$HW_DIR/map"; fi
assert_matches "$RUN_OUT$RUN_ERR" '0x[0-9a-fA-F]+' "map should print at least one address"
