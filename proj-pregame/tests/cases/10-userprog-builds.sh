#!/usr/bin/env bash
# Case: the Pintos kernel and userprog tests compile.
# Handout: Fall 2025 proj-pregame, docs/tasks/faulting_instruction — "run
# make and make check in the proj-pregame/src/userprog directory".
source "${TESTLIB:?run via tests/run.sh}"
require_cmd gcc perl
[ -d "$HW_DIR/src/userprog" ] || t_skip "pintos tree not present"
build "$HW_DIR/src/userprog"
assert_file_exists "$HW_DIR/src/userprog/build/kernel.bin"
assert_file_exists "$HW_DIR/src/userprog/build/tests/userprog/do-nothing"
