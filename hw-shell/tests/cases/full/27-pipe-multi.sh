#!/usr/bin/env bash
# Case: a three-stage pipeline works end to end.
# Handout: Fall 2025 hw-shell, docs/pipes. Buggy shells that leak pipe fds
# deadlock here — keep the timeout tight.
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR"
run -t 5 -i $'/bin/echo abc | /usr/bin/tr a-z A-Z | /usr/bin/wc -c\n' "$HW_DIR/shell"
[ "$RUN_STATUS" != 124 ] || t_fail "3-stage pipeline deadlocked (unused pipe ends not closed?)"
assert_matches "$RUN_OUT" '(^|[^0-9])4([^0-9]|$)' "expected 4 (ABC + newline)"
