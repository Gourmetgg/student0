#!/usr/bin/env bash
# Case (TODO): multiple requests/responses over ONE proxied connection.
# Handout: Fall 2025 hw-http, docs/tasks/proxy — "Your proxy must support
# multiple requests/responses" within the same connection.
source "${TESTLIB:?run via tests/run.sh}"
require_full
t_todo "open one TCP connection to the proxy (python3 socket or exec 3<>/dev/tcp), \
send two GETs back-to-back with Connection: keep-alive, assert two full \
responses arrive on the same fd."
