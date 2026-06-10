#!/usr/bin/env bash
# Case (TODO, extra credit): `cmd &` returns the prompt immediately.
# Handout: Fall 2025 hw-shell, docs/foreground-background/background-processes.
source "${TESTLIB:?run via tests/run.sh}"
require_full
t_todo "feed 'sleep 5 &' then '/bin/echo prompt-back' and assert prompt-back \
appears well before 5s (wall-clock the run; budget ~2s)."
