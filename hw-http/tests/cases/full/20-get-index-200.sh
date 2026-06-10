#!/usr/bin/env bash
# Case: GET /index.html returns 200 with correct headers and exact body.
# Handout: Fall 2025 hw-http, docs/tasks/get_request (Files) — Content-Length
# must equal the body size in bytes.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd curl
build "$HW_DIR" all
port="$(pick_port)"
spawn "$HW_DIR/httpserver" --files "$HW_DIR/www" --port "$port"
wait_tcp 127.0.0.1 "$port" 5
hdr="$T_TMP/h"; body="$T_TMP/b"
must_run -t 5 curl -s --noproxy '*' -D "$hdr" -o "$body" "http://127.0.0.1:$port/index.html"
assert_matches "$(cat "$hdr")" 'HTTP/1\.[01] 200' "status line"
assert_matches "$(cat "$hdr")" 'Content-Type: *text/html' "Content-Type header"
want_len="$(wc -c < "$HW_DIR/www/index.html")"
assert_matches "$(cat "$hdr")" "Content-Length: *$want_len" "Content-Length == body bytes"
assert_same_file "$HW_DIR/www/index.html" "$body" "body must be byte-exact"
