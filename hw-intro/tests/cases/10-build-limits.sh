#!/usr/bin/env bash
# Case: `make limits` builds on the pristine starter.
# Handout: Fall 2025 hw-intro, docs/user-limits ("You can run make limits").
source "${TESTLIB:?run via tests/run.sh}"
build "$HW_DIR" limits
assert_executable "$HW_DIR/limits"
