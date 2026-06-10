#!/usr/bin/env bash
# Case: all four server variants compile from the single source.
# Handout: Fall 2025 hw-http, docs/tasks/servers (httpserver, forkserver,
# threadserver, poolserver via #ifdef conditional compilation).
source "${TESTLIB:?run via tests/run.sh}"
build "$HW_DIR" all
for b in httpserver forkserver threadserver poolserver; do
  assert_executable "$HW_DIR/$b"
done
