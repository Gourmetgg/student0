#!/usr/bin/env bash
# Case: submitting an invalid app name yields an error, not a valid job id.
# Mirrors the autograder's `submit-bad-app` test.
# Handout: Fall 2025 hw-map-reduce, docs/background/development (test list).
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_rpcbind
build "$HW_DIR"
cd "$HW_DIR"
spawn ./bin/mr-coordinator
sleep 1
run -t 15 ./bin/mr-client submit -a not-a-real-app -n 2 -o "$T_TMP/x" -w data/gutenberg/p.txt
[ "$RUN_STATUS" -ne 0 ] || assert_matches "$RUN_OUT$RUN_ERR" '[Ee]rror|[Ii]nvalid' \
  "bad app must be rejected (job_id = -1), got exit 0 with no error text"
