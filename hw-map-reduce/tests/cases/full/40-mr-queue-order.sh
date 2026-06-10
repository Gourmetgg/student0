#!/usr/bin/env bash
# Case (TODO): jobs run first-come-first-served. Mirrors `mr-queue-order`.
# Handout hint: tasks for job 1 must be assigned before tasks for job 2.
source "${TESTLIB:?run via tests/run.sh}"
require_full
t_todo "submit two jobs back-to-back with ONE worker; from coordinator logs \
(add printf per GET_TASK) assert every job-0 task id precedes job-1's."
