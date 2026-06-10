#!/usr/bin/env bash
# Case (TODO): limits' numbers agree with the shell's own soft limits.
# Handout: Fall 2025 hw-intro, docs/user-limits.
source "${TESTLIB:?run via tests/run.sh}"
require_full
t_todo "compare 'stack size' with \$(ulimit -Ss)*1024 and 'max file \
descriptors' with \$(ulimit -Sn); allow the documented negative process-limit \
quirk in Docker."
