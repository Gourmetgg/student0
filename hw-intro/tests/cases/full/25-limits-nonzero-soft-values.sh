#!/usr/bin/env bash
# Case: limits prints real (non-zero) soft limits once implemented.
# Handout: Fall 2025 hw-intro, docs/user-limits — "use the soft limits, not
# the hard limits". The Docker workspace may legitimately show a negative
# process limit; treat any non-zero integer as implemented.
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR" limits
run -t 5 "$HW_DIR/limits"
for field in "stack size" "max file descriptors"; do
  val="$(printf '%s\n' "$RUN_OUT" | sed -n "s/^$field: *//p")"
  [ -n "$val" ] || t_fail "missing line '$field: ...'"
  [ "$val" != "0" ] || t_fail "$field still prints the starter value 0"
done
