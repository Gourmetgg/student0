#!/usr/bin/env bash
# Case (TODO): prove the synchronization is fine-grained, not a global lock.
# Handout: Fall 2025 hw-list, docs/pwords — a global lock around count_words
# is explicitly unacceptable ("we reserve the right to deduct points").
source "${TESTLIB:?run via tests/run.sh}"
require_full
t_todo "wrap two slow inputs (e.g. FIFOs fed at a fixed rate, or large \
gutenberg files) and assert wall-clock(pwords) is well under the sum of \
per-file times — concurrent reads prove count_words isn't serialized."
