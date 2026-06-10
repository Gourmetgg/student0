#!/usr/bin/env bash
# Case (TODO): poolserver serves exactly --num-threads clients concurrently.
# Handout: Fall 2025 hw-http, docs/tasks/servers — "concurrently serve exactly
# --num-threads clients and no more".
source "${TESTLIB:?run via tests/run.sh}"
require_full
t_todo "serve a slow endpoint (big file + tiny socket buffer, or a FIFO), open \
N+2 clients with --num-threads N, assert N progress while 2 are queued — e.g. \
by timing first-byte arrival."
