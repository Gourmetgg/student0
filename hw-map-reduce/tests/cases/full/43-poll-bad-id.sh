#!/usr/bin/env bash
# Case (TODO): polling an invalid job id errors without crashing the
# coordinator. Mirrors `poll-bad-id`.
source "${TESTLIB:?run via tests/run.sh}"
require_full
t_todo "needs a tiny RPC client (copy client/client.c poll path) that calls \
POLL_JOB with id 9999; assert invalid_job_id=true AND that a subsequent \
valid submit still works (coordinator alive)."
