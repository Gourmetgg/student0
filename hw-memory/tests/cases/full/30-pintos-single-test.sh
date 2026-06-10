#!/usr/bin/env bash
# Case: run ONE official Pintos memory test end-to-end under qemu (sbrk-zero:
# sbrk(0) returns the initial break). Faster feedback than the full 26.
# Handout: Fall 2025 hw-memory, docs/sbrk — official suite via `make check`.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_qemu
require_cmd perl
build "$HW_DIR/pintos/src/memory"
d="$HW_DIR/pintos/src/memory"
( cd "$d" && PATH="$d/../utils:$PATH" timeout 240 \
    make build/tests/memory/sbrk-zero.result ) >"$T_TMP/out" 2>&1 \
  || { tail -15 "$T_TMP/out" | sed 's/^/    /'; t_fail "sbrk-zero did not run"; }
grep -q "pass tests/memory/sbrk-zero" "$T_TMP/out" "$d"/build/tests/memory/sbrk-zero.result 2>/dev/null \
  || { tail -15 "$T_TMP/out" | sed 's/^/    /'; t_fail "sbrk-zero FAILED (expected until sbrk is implemented)"; }
