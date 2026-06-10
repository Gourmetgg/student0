#!/usr/bin/env bash
# Case: the starter shell compiles and links.
# Handout: Fall 2025 hw-shell "Getting started" (snapshot 20251110134217).
source "${TESTLIB:?run via tests/run.sh}"
build "$HW_DIR"
assert_executable "$HW_DIR/shell"
