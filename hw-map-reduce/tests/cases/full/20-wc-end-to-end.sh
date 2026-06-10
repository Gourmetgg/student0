#!/usr/bin/env bash
# Case: full wc job — submit, wait, process, compare against the provided
# ./words oracle. Mirrors the autograder's `wc` test.
# Handout: Fall 2025 hw-map-reduce, docs/background/development (Usage):
#   ./bin/mr-client submit -a wc -o out -w -n 10 data/gutenberg/*
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
spawn ./bin/mr-worker
in1=data/gutenberg/p.txt; in2=data/gutenberg/q.txt
[ -f "$in1" ] && [ -f "$in2" ] || t_skip "gutenberg inputs missing"
must_run -t 120 ./bin/mr-client submit -a wc -n 4 -o "$out" -w "$in1" "$in2"
run -t 60 ./bin/mr-client process -a wc -n 4 -o "$out"
[ "$RUN_STATUS" -eq 0 ] || t_fail "mr-client process failed"
want="$(./words "$in1" "$in2" | sort)"
got="$(printf '%s\n' "$RUN_OUT" | sort)"
assert_eq "$got" "$want" "wc output != ./words oracle"
