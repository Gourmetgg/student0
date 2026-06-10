#!/usr/bin/env bash
# Case (TODO): collect the ab(1) numbers the handout asks you to study.
# Handout: Fall 2025 hw-http, docs/tasks/performance — ab -n 500 -c 10 against
# all four variants; record mean time per request in REPORT.md §Performance.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd ab
t_todo "loop over httpserver/forkserver/threadserver/poolserver: start on a \
fresh port, ab -n 500 -c 10, extract 'Time per request', append a table to \
\$T_TMP/ab.txt and paste it into REPORT.md."
