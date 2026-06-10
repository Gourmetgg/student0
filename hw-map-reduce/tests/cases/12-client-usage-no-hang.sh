#!/usr/bin/env bash
# Case: mr-client without arguments prints usage promptly (no hang).
# Handout: Fall 2025 hw-map-reduce, docs/background/development — argument
# parsing is provided by the starter.
source "${TESTLIB:?run via tests/run.sh}"
require_cmd rpcgen pkg-config
pkg-config --exists glib-2.0 || t_skip "libglib2.0-dev not installed"
[ -e /usr/include/tirpc/rpc/rpc.h ] || t_skip "libtirpc-dev not installed"
build "$HW_DIR"
run -t 3 "$HW_DIR/bin/mr-client"
[ "$RUN_STATUS" != 124 ] || t_fail "mr-client hangs with no args"
assert_matches "$RUN_OUT$RUN_ERR" "[Uu]sage|subcommand" "should print usage/subcommands"
