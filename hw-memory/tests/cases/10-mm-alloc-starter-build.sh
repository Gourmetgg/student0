#!/usr/bin/env bash
# Case: report mm_alloc's build state. The pristine Fall25 starter does NOT
# compile (-Wall -Werror -Wextra vs. empty TODO stubs) — that is expected, so
# this SKIPs instead of failing. Once you start implementing, it must build.
# Handout: Fall 2025 hw-memory, docs/library-functions/introduction.
source "${TESTLIB:?run via tests/run.sh}"
if try_build "$HW_DIR/mm_alloc"; then
  assert_executable "$HW_DIR/mm_alloc/mm_test"
else
  tail -n 6 "$TRY_BUILD_LOG" | sed 's/^/    /'
  t_skip "mm_alloc does not compile on the pristine starter (expected until implemented)"
fi
