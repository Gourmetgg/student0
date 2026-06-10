#!/usr/bin/env bash
# Case (TODO, extra credit): `fg`/`bg` move jobs between fore/background.
# Handout: Fall 2025 hw-shell, docs/foreground-background/switching.
source "${TESTLIB:?run via tests/run.sh}"
require_full
require_cmd python3
t_todo "pty harness: 'sleep 30 &', then 'fg' — assert the shell now waits; \
Ctrl-Z, then 'bg' — assert sleep resumes in background (state S, prompt live)."
