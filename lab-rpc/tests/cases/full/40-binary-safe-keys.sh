#!/usr/bin/env bash
# Case (TODO): keys/values with embedded NUL bytes survive PUT/GET.
# Handout: Fall 2025 lab-rpc, docs/kv-store — "keys and values are not
# necessarily NULL terminated". argv can't carry NULs, so this needs a tiny
# C driver linked against kv_store_client.h.
source "${TESTLIB:?run via tests/run.sh}"
require_full
t_todo "write tests/fixtures/binary_kv.c: build a buf{len,val} with embedded \
NULs, call put()/get() from kv_store_client.h, memcmp the round-trip; compile \
it in this case like hw-memory's mm_behavior driver."
