#!/usr/bin/env bash
# Case (TODO): no task is ever assigned twice (absent crashes). Mirrors
# `mr-no-duplicates` / `crash-no-duplicates`.
source "${TESTLIB:?run via tests/run.sh}"
require_full
t_todo "run wc with 5 workers; log (job_id, task, reduce) per GET_TASK reply; \
assert the multiset has no duplicates while all workers stay alive."
