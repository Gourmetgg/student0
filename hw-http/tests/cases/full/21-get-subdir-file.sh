#!/usr/bin/env bash
# Case: files in subdirectories of --files are reachable.
# Handout: Fall 2025 hw-http, docs/tasks/get_request — "handle requests to
# files in subdirectories of the files directory".
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd curl
build "$HW_DIR" all
f="$(find "$HW_DIR/www" -mindepth 2 -type f | head -1)"
[ -n "$f" ] || t_skip "www/ has no files in subdirectories"
rel="${f#"$HW_DIR/www/"}"
port="$(pick_port)"
spawn "$HW_DIR/httpserver" --files "$HW_DIR/www" --port "$port"
wait_tcp 127.0.0.1 "$port" 5
body="$T_TMP/b"
must_run -t 5 curl -sf --noproxy '*' -o "$body" "http://127.0.0.1:$port/$rel"
assert_same_file "$f" "$body" "subdirectory file body"
