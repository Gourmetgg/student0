/*
 * mm_behavior.c — behavior checks for the Fall 2025 mm_alloc spec
 * (hw-memory, docs/library-functions/memory-allocator).
 *
 * Compiled by tests/cases/full/21-mm-behavior-driver.sh against your
 * mm_alloc.o. Each check cites the handout rule it enforces. Extend freely —
 * this is yours to grow into the exhaustive suite mm_test.c never was.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "mm_alloc.h"

static int failures = 0;

#define CHECK(cond, msg)                                                       \
  do {                                                                         \
    if (cond) {                                                                \
      printf("ok   %s\n", msg);                                                \
    } else {                                                                   \
      printf("FAIL %s\n", msg);                                                \
      failures++;                                                              \
    }                                                                          \
  } while (0)

int main(void) {
  /* "please zero-fill your allocated memory" */
  char* p = mm_malloc(64);
  CHECK(p != NULL, "mm_malloc(64) returns memory");
  int zeroed = 1;
  for (int i = 0; p && i < 64; i++)
    if (p[i] != 0) zeroed = 0;
  CHECK(zeroed, "allocated memory is zero-filled");

  /* "Return NULL if the requested size is 0." */
  CHECK(mm_malloc(0) == NULL, "mm_malloc(0) returns NULL");

  /* "Your deallocation function should do nothing if passed a NULL pointer." */
  mm_free(NULL);
  CHECK(1, "mm_free(NULL) does not crash");

  /* first fit: a freed block is reused for a request that fits */
  if (p) {
    memset(p, 0xAB, 64);
    char* q = mm_malloc(64);
    CHECK(q != NULL && q != p, "second allocation is a distinct block");
    mm_free(p);
    char* r = mm_malloc(32);
    CHECK(r == p, "freed block is reused first-fit for a smaller request");
    int rezeroed = 1;
    for (int i = 0; r && i < 32; i++)
      if (r[i] != 0) rezeroed = 0;
    CHECK(rezeroed, "reused block is zero-filled again");
    mm_free(r);
    mm_free(q);
  }

  /* "mm_realloc(NULL, n) is equivalent to calling mm_malloc(n)" */
  char* a = mm_realloc(NULL, 16);
  CHECK(a != NULL, "mm_realloc(NULL, 16) behaves like mm_malloc");

  /* "mm_realloc(NULL, 0) ... should just return NULL" */
  CHECK(mm_realloc(NULL, 0) == NULL, "mm_realloc(NULL, 0) returns NULL");

  /* grow preserves old data */
  if (a) {
    memcpy(a, "cs162-memory!!!", 16);
    char* b = mm_realloc(a, 256);
    CHECK(b != NULL, "mm_realloc grow returns memory");
    CHECK(b && memcmp(b, "cs162-memory!!!", 16) == 0,
          "mm_realloc grow preserves the old bytes");
    /* "mm_realloc(ptr, 0) is equivalent to calling mm_free(ptr)" */
    CHECK(mm_realloc(b, 0) == NULL, "mm_realloc(ptr, 0) frees and returns NULL");
  }

  /* "you must coalesce consecutive free blocks" — after freeing two adjacent
     blocks, a request spanning both must fit at the first one's address. */
  char* c1 = mm_malloc(64);
  char* c2 = mm_malloc(64);
  char* c3 = mm_malloc(64); /* guard so the heap top isn't the freed region */
  if (c1 && c2 && c3) {
    mm_free(c1);
    mm_free(c2);
    char* big = mm_malloc(96); /* > 64, fits only if c1+c2 coalesced */
    CHECK(big == c1, "adjacent free blocks coalesce (96B lands at first block)");
    mm_free(big);
    mm_free(c3);
  } else {
    CHECK(0, "setup allocations for the coalescing check");
  }

  printf("---\n%s (%d failure%s)\n", failures ? "FAILED" : "PASSED", failures,
         failures == 1 ? "" : "s");
  return failures ? 1 : 0;
}
