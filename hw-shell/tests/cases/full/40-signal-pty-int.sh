#!/usr/bin/env bash
# Case (TODO): Ctrl-C kills only the foreground job; the shell survives.
# Handout: Fall 2025 hw-shell, docs/signal-handling/task — "your shell should
# not terminate upon receiving Ctrl + C"; stopping/interrupt signals must hit
# the foreground process group only.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd python3
t_todo "drive ./shell under python3 pty.fork(): start 'sleep 30', send SIGINT \
to the pty foreground group, then send '/bin/echo alive' and assert the shell \
answers. See Handbook, 'Signals require a pty'."
