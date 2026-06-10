#!/usr/bin/env bash
# Case: `make` produces all four binaries on the pristine starter.
# Handout: Fall 2025 hw-list, Getting started — "run make, which should create
# four binaries: pthread, words, pwords, and lwords".
source "${TESTLIB:?run via tests/run.sh}"
build "$HW_DIR" all
for b in pthread words pwords lwords; do assert_executable "$HW_DIR/$b"; done
