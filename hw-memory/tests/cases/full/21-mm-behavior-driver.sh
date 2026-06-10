#!/usr/bin/env bash
# Case: the Fall25 mm_alloc spec checks in tests/fixtures/mm_behavior.c —
# zero-fill, malloc(0), free(NULL), first-fit reuse, realloc edge cases,
# coalescing. Extend that file as you harden your allocator.
# Handout: Fall 2025 hw-memory, docs/library-functions/memory-allocator.
source "${TESTLIB:?run via tests/run.sh}"
require_full
build "$HW_DIR/mm_alloc" mm_alloc.o
gcc -g3 -Wall -std=c99 -I"$HW_DIR/mm_alloc" \
    "$(fixture mm_behavior.c)" "$HW_DIR/mm_alloc/mm_alloc.o" \
    -o "$T_TMP/mm_behavior" || t_fail "could not compile the behavior driver"
run -t 10 "$T_TMP/mm_behavior"
printf '%s\n' "$RUN_OUT" | sed 's/^/    /'
[ "$RUN_STATUS" -eq 0 ] || t_fail "mm_behavior checks failed"
