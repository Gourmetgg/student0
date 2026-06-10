#!/usr/bin/env bash
# Case: the crate builds on the pristine starter (todo!()s compile fine).
# Handout: Fall 2025 hw-http-rs, Getting started.
source "${TESTLIB:?run via tests/run.sh}"
require_cmd cargo
cargo_build "$HW_DIR"
