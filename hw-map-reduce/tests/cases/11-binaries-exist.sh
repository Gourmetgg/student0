#!/usr/bin/env bash
# Case: bin/mr-coordinator, bin/mr-worker, bin/mr-client all exist after make.
# Handout: Fall 2025 hw-map-reduce, docs/background/development — "Running
# make creates 3 binaries in the bin/ folder".
source "${TESTLIB:?run via tests/run.sh}"
require_cmd rpcgen pkg-config
pkg-config --exists glib-2.0 || t_skip "libglib2.0-dev not installed"
[ -e /usr/include/tirpc/rpc/rpc.h ] || t_skip "libtirpc-dev not installed"
build "$HW_DIR"
for b in mr-coordinator mr-worker mr-client; do
  assert_executable "$HW_DIR/bin/$b"
done
