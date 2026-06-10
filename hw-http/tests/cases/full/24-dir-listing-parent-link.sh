#!/usr/bin/env bash
# Case: a directory without index.html lists children and links to the parent.
# Handout: Fall 2025 hw-http, docs/tasks/get_request (Directories) — links to
# all immediate children "as well as a link to the parent directory".
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd curl
build "$HW_DIR" all
d="$(find "$HW_DIR/www" -mindepth 1 -maxdepth 1 -type d ! -exec test -e '{}/index.html' \; -print | head -1)"
[ -n "$d" ] || t_skip "www/ has no index-less subdirectory"
rel="${d#"$HW_DIR/www/"}"
child="$(ls "$d" | head -1)"
port="$(pick_port)"
spawn "$HW_DIR/httpserver" --files "$HW_DIR/www" --port "$port"
wait_tcp 127.0.0.1 "$port" 5
run -t 5 curl -sf --noproxy '*' "http://127.0.0.1:$port/$rel/"
[ "$RUN_STATUS" -eq 0 ] || t_fail "directory request failed"
assert_contains "$RUN_OUT" "$child" "listing should include child entries"
assert_matches "$RUN_OUT" 'href="[^"]*\.\./?"|[Pp]arent' "listing must link to the parent directory"
