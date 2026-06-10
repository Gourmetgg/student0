#!/usr/bin/env bash
# Case (TODO): each spawned program runs in its own process group and the
# foreground group owns the terminal.
# Handout: Fall 2025 hw-shell, docs/signal-handling/task — "ensure that each
# program you start is in its own process group ... placed in the foreground".
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd python3
t_todo "pty harness: run 'ps -o pid,pgid,tpgid -p \$\$' from inside the shell \
and assert the child's PGID != shell's PGID and TPGID == child's PGID."
