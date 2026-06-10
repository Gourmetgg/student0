#!/usr/bin/env bash
# Case: a nonexistent path yields 404 Not Found.
# Handout: Fall 2025 hw-http, docs/tasks/get_request — "serve a 404 Not Found
# response (the HTTP body is optional)".
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd curl
build "$HW_DIR" all
port="$(pick_port)"
spawn "$HW_DIR/httpserver" --files "$HW_DIR/www" --port "$port"
wait_tcp 127.0.0.1 "$port" 5
run -t 5 curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/definitely-missing.txt"
assert_eq "$RUN_OUT" "404" "missing file must 404"
