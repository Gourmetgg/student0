#!/usr/bin/env bash
# Case (TODO): negative sbrk deallocates pages — the freed page count returns
# to the pool (sbrk-dealloc covers basics; write a multi-page shrink probe).
# Handout: Fall 2025 hw-memory, docs/sbrk/syscall-implementation.
source "${TESTLIB:?run via tests/run.sh}"
require_full
t_todo "user test: grow the heap by 8 pages, write a sentinel in page 1, \
shrink by 8 pages, assert sbrk(0) moved back and that re-growing yields \
zeroed pages (no stale sentinel)."
