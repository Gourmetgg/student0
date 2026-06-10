#!/usr/bin/env bash
# Case (TODO): pwords runs clean under a race detector.
# Handbook: "Concurrency" chapter (helgrind / ThreadSanitizer).
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd valgrind
t_todo "valgrind --tool=helgrind --error-exitcode=1 ./pwords on the fixtures; \
expect exit 0 once locking is correct (slow: keep inputs small)."
