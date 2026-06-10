#!/usr/bin/env bash
# Case: binary files (e.g. .jpg) survive the read/write loop byte-exact.
# Handout: Fall 2025 hw-http, docs/tasks/get_request — partial read/write
# handling is the point of the syscall requirement.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd curl
build "$HW_DIR" all
f="$(find "$HW_DIR/www" -type f \( -name '*.jpg' -o -name '*.png' -o -name '*.gif' \) | head -1)"
[ -n "$f" ] || t_skip "no binary fixture under www/"
rel="${f#"$HW_DIR/www/"}"
port="$(pick_port)"
spawn "$HW_DIR/httpserver" --files "$HW_DIR/www" --port "$port"
wait_tcp 127.0.0.1 "$port" 5
body="$T_TMP/b"
must_run -t 10 curl -sf --noproxy '*' -o "$body" "http://127.0.0.1:$port/$rel"
cmp -s "$f" "$body" || t_fail "binary body differs from the file on disk"
