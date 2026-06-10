#!/usr/bin/env bash
# Case: bin/server and bin/client exist after make.
# Handout: Fall 2025 lab-rpc, Usage.
source "${TESTLIB:?run via tests/run.sh}"
require_cmd rpcgen pkg-config
pkg-config --exists glib-2.0 || t_skip "libglib2.0-dev not installed"
[ -e /usr/include/tirpc/rpc/rpc.h ] || t_skip "libtirpc-dev not installed"
build "$HW_DIR"
assert_executable "$HW_DIR/bin/server"
assert_executable "$HW_DIR/bin/client"
