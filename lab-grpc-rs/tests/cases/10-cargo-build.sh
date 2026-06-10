#!/usr/bin/env bash
# Case: the crate builds on the pristine starter (Example RPC only).
# Handout: Fall 2025 lab-grpc-rs, Getting started (CMake >= 3.20 needed for
# protobuf codegen via tonic-build).
source "${TESTLIB:?run via tests/run.sh}"
require_cmd cargo
cargo_build "$HW_DIR"
