#!/usr/bin/env bash
# Case: the full official suite — all 26 memory tests (15 sbrk + 11
# malloc/realloc). Slow: run with a raised case budget, e.g.
#   CASE_TIMEOUT=3600 RUN_FULL=1 bash tests/run.sh 'full/31*'
# Handout: Fall 2025 hw-memory, docs/sbrk/introduction (make check).
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_qemu
require_cmd perl
[ "${CASE_TIMEOUT:-300}" -ge 1800 ] \
  || t_skip "needs CASE_TIMEOUT>=1800 (the suite takes ~10-30 min; sbrk-oom-2 alone allows 300s)"
build "$HW_DIR/pintos/src/memory"
d="$HW_DIR/pintos/src/memory"
( cd "$d" && PATH="$d/../utils:$PATH" make check ) >"$T_TMP/out" 2>&1 || true
pass_n="$(grep -c '^pass ' "$T_TMP/out" || true)"
fail_n="$(grep -c '^FAIL ' "$T_TMP/out" || true)"
t_diag "pintos memory suite: $pass_n pass, $fail_n fail (expect 26 pass when done)"
grep -E '^(pass|FAIL) ' "$T_TMP/out" | sed 's/^/    /'
[ "$fail_n" -eq 0 ] && [ "$pass_n" -ge 26 ] || t_fail "official suite not fully green yet"
