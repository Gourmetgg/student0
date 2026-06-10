#!/usr/bin/env bash
# Case (TODO): Ctrl-Z stops the foreground job only (shell keeps running).
# Handout: Fall 2025 hw-shell, docs/signal-handling/task — stopping signals
# should only affect the foregrounded program, not the backgrounded shell.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd python3
t_todo "pty harness: run 'sleep 30', deliver SIGTSTP to the fg group, assert \
the shell prompt returns while sleep is in state T (check /proc/<pid>/stat)."
