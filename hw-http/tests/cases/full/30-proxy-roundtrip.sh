#!/usr/bin/env bash
# Case: proxy mode relays requests to an upstream server and back.
# Handout: Fall 2025 hw-http, docs/tasks/proxy — two-way communication; close
# both sockets when either side closes.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd curl
build "$HW_DIR" all
up="$(pick_port)"
spawn "$HW_DIR/httpserver" --files "$HW_DIR/www" --port "$up"
wait_tcp 127.0.0.1 "$up" 5
px="$(pick_port)"
spawn "$HW_DIR/httpserver" --proxy "127.0.0.1:$up" --port "$px"
wait_tcp 127.0.0.1 "$px" 5
body="$T_TMP/b"
must_run -t 10 curl -sf --noproxy '*' -o "$body" "http://127.0.0.1:$px/index.html"
assert_same_file "$HW_DIR/www/index.html" "$body" "proxied body"
must_run -t 10 curl -sf --noproxy '*' -o "$body" "http://127.0.0.1:$px/index.html"
assert_same_file "$HW_DIR/www/index.html" "$body" "second proxied request"
