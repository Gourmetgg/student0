#!/usr/bin/env bash
# Case (TODO): a worker killed mid-map gets its task reassigned after
# TASK_TIMEOUT_SECS. Mirrors `map-crash` (handout suggests adding a sleep
# after get_task_1 in worker.c line ~23 and Ctrl-C-ing the worker).
source "${TESTLIB:?run via tests/run.sh}"
require_full
t_todo "start coordinator + 2 workers; SIGKILL one right after it logs task \
receipt; assert the job still completes and output matches ./words."
