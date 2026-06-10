#!/usr/bin/env bash
# Case: poolserver with --num-threads serves GETs via the work queue.
# Handout: Fall 2025 hw-http, docs/tasks/servers (Pool server).
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd curl
build "$HW_DIR" all
port="$(pick_port)"
spawn "$HW_DIR/poolserver" --files "$HW_DIR/www" --port "$port" --num-threads 4
wait_tcp 127.0.0.1 "$port" 5
body="$T_TMP/b"
must_run -t 5 curl -sf --noproxy '*' -o "$body" "http://127.0.0.1:$port/"
assert_same_file "$HW_DIR/www/index.html" "$body"
