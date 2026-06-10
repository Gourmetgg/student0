#!/usr/bin/env bash
# Case: rpcgen + server + client build on the pristine starter.
# Handout: Fall 2025 lab-rpc, Usage — `make` generates stubs and bin/{server,client}.
source "${TESTLIB:?run via tests/run.sh}"
require_cmd rpcgen
[ -e /usr/include/tirpc/rpc/rpc.h ] || t_skip "libtirpc-dev not installed (sudo apt install libtirpc-dev)"
require_cmd pkg-config
pkg-config --exists glib-2.0 || t_skip "libglib2.0-dev not installed"
build "$HW_DIR"
