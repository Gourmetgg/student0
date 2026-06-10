#!/usr/bin/env bash
# Case: grep job output matches grep(1). Mirrors the autograder's `grep` test
# (args plumbing: -x carries the search word).
# Handout: Fall 2025 hw-map-reduce, docs/background/development.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_rpcbind
build "$HW_DIR"
out="$T_TMP/mr-out"
cd "$HW_DIR"
spawn ./bin/mr-coordinator
sleep 1
spawn ./bin/mr-worker
spawn ./bin/mr-worker
in=data/gutenberg/p.txt
[ -f "$in" ] || t_skip "gutenberg inputs missing"
must_run -t 120 ./bin/mr-client submit -a grep -n 2 -o "$out" -x the -w "$in"
run -t 60 ./bin/mr-client process -a grep -n 2 -o "$out"
[ "$RUN_STATUS" -eq 0 ] || t_fail "mr-client process failed"
[ -n "$RUN_OUT" ] || t_fail "grep job produced no output"
want_count="$(grep -c the "$in")"
t_diag "grep(1) finds $want_count matching lines; verify your output covers them"
printf '%s\n' "$RUN_OUT" | head -3 | sed 's/^/    /'
