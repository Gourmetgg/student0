#!/usr/bin/env bash
# Case: GET / serves www/index.html (directory containing index.html).
# Handout: Fall 2025 hw-http, docs/tasks/get_request (Directories).
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd curl
build "$HW_DIR" all
port="$(pick_port)"
spawn "$HW_DIR/httpserver" --files "$HW_DIR/www" --port "$port"
wait_tcp 127.0.0.1 "$port" 5
body="$T_TMP/b"
must_run -t 5 curl -sf --noproxy '*' -o "$body" "http://127.0.0.1:$port/"
assert_same_file "$HW_DIR/www/index.html" "$body" "GET / must serve index.html"
