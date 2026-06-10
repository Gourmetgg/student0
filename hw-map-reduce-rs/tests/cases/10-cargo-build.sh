#!/usr/bin/env bash
# Case: the crate builds on the pristine starter.
# Handout: Fall 2025 hw-map-reduce-rs, Getting started (local dev recommended;
# tonic-build needs CMake >= 3.20 for protobuf codegen).
source "${TESTLIB:?run via tests/run.sh}"
require_cmd cargo
cargo_build "$HW_DIR"
