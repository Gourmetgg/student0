#!/usr/bin/env bash
# Case (TODO): words are lowercased and counted case-insensitively.
# Handout: Fall 2025 hw-intro, docs/counting-words ("AaA" and "aaa" merge).
source "${TESTLIB:?run via tests/run.sh}"
require_full
t_todo "fixture 'Foo FOO foo' → total 3; -f output exactly '3 foo' (one row, \
lowercase)."
