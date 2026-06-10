#!/usr/bin/env bash
# Case (TODO): Get on a missing key returns exactly
# Err(Status::new(Code::NotFound, "Key does not exist.")).
# Handout: Fall 2025 lab-grpc-rs, docs/kv-store — the autograder checks this
# contract; assert both the gRPC code and the message text.
source "${TESTLIB:?run via tests/run.sh}"
require_full
t_todo "run client get missing-key; assert non-zero exit and stderr contains \
'NotFound' and 'Key does not exist.' (or add a unit test in src/server.rs \
calling get directly and matching status.code() == Code::NotFound)."
