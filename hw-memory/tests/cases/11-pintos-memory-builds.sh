#!/usr/bin/env bash
# Case: the Pintos kernel + memory test programs compile on this host.
# Handout: Fall 2025 hw-memory, docs/sbrk/introduction — official check is
# `cd pintos/src/memory && make check`; building is the qemu-free part.
source "${TESTLIB:?run via tests/run.sh}"
require_cmd gcc perl
[ -d "$HW_DIR/pintos/src/memory" ] || t_skip "pintos tree not present"
build "$HW_DIR/pintos/src/memory"
assert_file_exists "$HW_DIR/pintos/src/memory/build/kernel.bin"
