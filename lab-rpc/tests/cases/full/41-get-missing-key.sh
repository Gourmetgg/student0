#!/usr/bin/env bash
# Case (TODO): GET for an absent key reports an error/empty result without
# crashing the server, and the server survives for subsequent requests.
source "${TESTLIB:?run via tests/run.sh}"
require_full
t_todo "decide your contract (the C handout leaves it to you — document it \
in REPORT.md), then assert: get missing-key exits/prints accordingly AND a \
following 'example 1' still answers 2 (server alive)."
