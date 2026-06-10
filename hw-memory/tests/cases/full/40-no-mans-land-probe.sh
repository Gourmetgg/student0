#!/usr/bin/env bash
# Case (TODO): explore the "no man's land" between the break and the next
# page boundary — reads/writes there do NOT fault.
# Handout: Fall 2025 hw-memory, docs/sbrk/additional-information.
source "${TESTLIB:?run via tests/run.sh}"
require_full
t_todo "write a tiny Pintos user test: sbrk(10), write at break+1 (same page) \
— must not fault; then read one byte past the page boundary and expect the \
process to be killed. Add it to Make.tests like the sbrk-* tests."
