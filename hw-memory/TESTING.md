# HW 4 — Writing the Test Suite

Companion to `mm_alloc/mm_test.c` and the Pintos suite. Read
[`docs/testing-tutorial.md`](../docs/testing-tutorial.md) first.

The homework has two halves: a standalone `mm_alloc` allocator and a
Pintos `sbrk` + libc. The test approach is very different for each.

## Standalone `mm_alloc`

### What you're testing

| Feature                                   | Test type     |
| ----------------------------------------- | ------------- |
| `mm_malloc(0)` returns valid pointer      | basic         |
| Returned pointer is 8/16-byte aligned     | bitmask       |
| Write every byte of an N-byte block       | memset/memcmp |
| `mm_free(NULL)` does not crash            | basic         |
| Reuse after `free` (placement check)      | addr identity |
| `mm_realloc` grow preserves old bytes     | memcmp        |
| `mm_realloc` shrink preserves prefix      | memcmp        |
| Many small allocs + frees                 | stress        |
| Coalescing actually reuses adjacent space | addr identity |
| Out-of-memory case (huge size)            | NULL return   |

### Recipe

1. **Extend `mm_test.c`.** It's already wired into the Makefile via
   `dlopen("hw3lib.so")`. Add asserts after each operation:

   ```c
   int *a = mm_malloc(0);  assert(a != NULL);
   int *b = mm_malloc(8);
   assert(((uintptr_t)b & 7) == 0);  // 8-byte aligned
   for (int i = 0; i < 2; i++) b[i] = 0xCAFEBABE;
   mm_free(b);
   mm_free(NULL);  // must not crash
   ```
2. **Alignment**. Allocate 100 blocks of varied sizes; assert each
   pointer's low bits.
3. **Write coverage**. `memset` the full block, then verify the bytes
   read back. Catches off-by-one in size accounting.
4. **Coalescing**. `mm_malloc(64); mm_malloc(64); mm_free(both);
   mm_malloc(128)` — if the third malloc returns one of the first
   two addresses, coalescing works. Pin this with an `assert`.
5. **Realloc grow**. `p = mm_malloc(8); fill; p = mm_realloc(p, 64);
   check first 8 bytes unchanged`.
6. **Realloc shrink**. Same but go from 64 → 8. The prefix is
   preserved; bytes past the shrink are gone.
7. **Stress**. 10 000 random alloc/free pairs. Run under
   AddressSanitizer (`-fsanitize=address`) to catch over-writes.

### `mm_alloc/Makefile` integration

The current `test:` target reports `SKIP` on starter because of
`-Werror=unused-parameter`. Once you fill in the bodies, the test
becomes:

```
PASS: mm_alloc built
PASS: mm_test ran
```

Add an `asan:` target that builds with `-fsanitize=address` and runs
the same test:

```make
asan:
	gcc $(CFLAGS) -fsanitize=address -shared -o hw3lib.so mm_alloc.c
	gcc $(CFLAGS) -fsanitize=address $(TEST_CFLAGS) -o mm_test \
	    mm_test.c $(TEST_LDFLAGS)
	./mm_test
```

## Pintos `sbrk` + libc

### Why the approach changes

You cannot run Pintos under valgrind or ASan. The kernel boots on a
32-bit i386 target under QEMU; the test harness is Perl `.ck` scripts
comparing captured output. So:

- **You write tests in Pintos's test framework**, not in bash.
- **Test cases live in `pintos/src/tests/memory/`**; the active set is
  enabled in `Make.tests`.
- **`make check`** runs every active test under QEMU and reports
  PASS/FAIL based on the `.ck` script.

### Recipe

1. **Enable the staff tests.** Run `make check` once in
   `pintos/src/memory/`. Some will fail until you implement sbrk; that
   list is your TODO list.
2. **Add one new test.** Copy an existing `mm_*.c` to
   `mm_yourname.c`. Adjust the `Make.tests` entry. Pintos rebuilds
   include it automatically.
3. **Write the `.ck`.** The `.ck` file is Perl that calls `check_expected`
   with the lines you expect to see (regex-matched, in or out of
   order). Read another `.ck` for the conventions.
4. **Test the error paths.** `sc-bad-arg` and `mm-bad-ptr` are the
   highest-value cases — they expose kernel boundary bugs.

### The `make check` target is not in `make test`

The repo-level `make test` does not run Pintos `make check` because
that requires QEMU and the i386 cross toolchain. In the course Docker:

```sh
cd pintos/src/memory
make
env PATH=../../utils:../utils:$PATH make check
```

Document the exact command in your submission.

## Try it yourself

1. Run `mm_test` under both valgrind and ASan. Do they catch the same
   bugs? Build a deliberate buffer overrun in your `mm_alloc` and see
   which tool flags it first.
2. Pintos `sbrk(0)` must be cheap. Time it before and after your
   implementation — add a Pintos test that does 1 M `sbrk(0)` calls
   and asserts under a wall-clock threshold. Why is wall-clock testing
   fragile in CI?
3. Build a test that calls `sbrk(huge_number)`. What should happen?
   What does it actually do? Pin both with a test.
4. Write a test that interleaves `mm_malloc` and `mm_realloc` until the
   heap is fragmented, then attempts one large `mm_malloc`. Predict
   pass/fail based on your coalescing strategy.
5. The Pintos `mm-vaddr` test verifies your allocator returns user-
   space pointers. If yours returns kernel addresses, the test panics
   the kernel. Predict why before you read the `.ck` script.

## Common pitfalls

- **`mm_malloc(0)` returns NULL** in some libc implementations. The
  spec says return a valid pointer. Pin the choice in a test.
- **Alignment policy is arch-specific.** x86-64 needs 16-byte alignment
  for `long double`; x86 needs 8. The course autograder runs on i386
  Pintos — pick the right invariant.
- **AddressSanitizer rejects user-space allocators.** ASan instruments
  `malloc`, not arbitrary user code. To make it work on `mm_alloc`,
  link without `-shared` and provide your own `main`.
- **Pintos memory leaks don't appear under valgrind.** They appear as
  panic-on-OOM during `make check`. Watch the test logs in
  `build/tests/memory/`.
