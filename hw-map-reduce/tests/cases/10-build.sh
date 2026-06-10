#!/usr/bin/env bash
# Case: the three binaries build (needs libtirpc-dev, libglib2.0-dev, rpcgen).
# Handout: Fall 2025 hw-map-reduce, docs/background/development (Usage).
source "${TESTLIB:?run via tests/run.sh}"
require_cmd rpcgen pkg-config
pkg-config --exists glib-2.0 || t_skip "libglib2.0-dev not installed (sudo apt install libglib2.0-dev)"
[ -e /usr/include/tirpc/rpc/rpc.h ] || t_skip "libtirpc-dev not installed (sudo apt install libtirpc-dev)"
build "$HW_DIR"
