#!/usr/bin/env bash
# Case: ./bin/client without arguments prints subcommands and exits.
# Handout: Fall 2025 lab-rpc, Usage (client.c is starter-provided).
source "${TESTLIB:?run via tests/run.sh}"
require_cmd rpcgen pkg-config
pkg-config --exists glib-2.0 || t_skip "libglib2.0-dev not installed"
[ -e /usr/include/tirpc/rpc/rpc.h ] || t_skip "libtirpc-dev not installed"
build "$HW_DIR"
run -t 3 "$HW_DIR/bin/client"
[ "$RUN_STATUS" != 124 ] || t_fail "client hangs with no args"
