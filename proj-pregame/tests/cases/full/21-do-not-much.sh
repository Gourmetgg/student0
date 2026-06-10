#!/usr/bin/env bash
# Case: the official autograder test `do-not-much` passes under qemu.
# Handout: Fall 2025 proj-pregame, docs/tasks/debug + docs/deliverables —
# full code credit = do-nothing, do-not-much, stack-align-v all passing.
# On the pristine starter this FAILS by design ("currently no tests pass").
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_qemu
require_cmd perl
build "$HW_DIR/src/userprog"
d="$HW_DIR/src/userprog"
( cd "$d" && PATH="$d/../utils:$PATH" timeout 240 \
    make build/tests/userprog/do-not-much.result ) >"$T_TMP/out" 2>&1 || true
if grep -q "pass tests/userprog/do-not-much" "$T_TMP/out" "$d/build/tests/userprog/do-not-much.result" 2>/dev/null; then
  exit 0
fi
tail -15 "$T_TMP/out" | sed 's/^/    /'
t_fail "do-not-much not passing (expected on the unfixed starter; see docs/tasks/debug)"
