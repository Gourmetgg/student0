#!/usr/bin/env bash
# Case: forkserver serves the same GET correctly (child per connection).
# Handout: Fall 2025 hw-http, docs/tasks/servers (Fork server).
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd curl
build "$HW_DIR" all
port="$(pick_port)"
spawn "$HW_DIR/forkserver" --files "$HW_DIR/www" --port "$port"
wait_tcp 127.0.0.1 "$port" 5
body="$T_TMP/b"
must_run -t 5 curl -sf --noproxy '*' -o "$body" "http://127.0.0.1:$port/"
assert_same_file "$HW_DIR/www/index.html" "$body"
run -t 5 curl -sf --noproxy '*' -o "$body" "http://127.0.0.1:$port/"
[ "$RUN_STATUS" -eq 0 ] || t_fail "second connection failed (parent stopped accepting?)"
