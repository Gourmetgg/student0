#!/usr/bin/env bash
# Case: 10 simultaneous clients all get correct bodies (threadserver).
# Handout: Fall 2025 hw-http, docs/tasks/servers + performance.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd curl
build "$HW_DIR" all
port="$(pick_port)"
spawn "$HW_DIR/threadserver" --files "$HW_DIR/www" --port "$port"
wait_tcp 127.0.0.1 "$port" 5
pids=""
for i in $(seq 1 10); do
  curl -sf --noproxy '*' -o "$T_TMP/b$i" "http://127.0.0.1:$port/" &
  pids="$pids $!"
done
rc=0
for p in $pids; do wait "$p" || rc=1; done
[ "$rc" -eq 0 ] || t_fail "some concurrent requests failed"
for i in $(seq 1 10); do
  cmp -s "$HW_DIR/www/index.html" "$T_TMP/b$i" || t_fail "client $i got a corrupt body"
done
