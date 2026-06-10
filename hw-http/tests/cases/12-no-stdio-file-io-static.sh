#!/usr/bin/env bash
# Case: httpserver.c must not use fread/fwrite for serving files.
# Handout: Fall 2025 hw-http, docs/tasks/get_request — "You must use the read
# and write syscalls ... Any implementations using fread or fwrite will not
# earn any credit." This mirrors that rule locally.
source "${TESTLIB:?run via tests/run.sh}"
if grep -nE '\bf(read|write)\s*\(' "$HW_DIR/httpserver.c"; then
  t_fail "httpserver.c uses fread/fwrite — earns no credit per the handout"
fi
