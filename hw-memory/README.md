HW 4: Memory
============

Official reference:

- <https://cs162.org/static/hw/hw-memory/>
- <https://cs162.org/static/hw/hw-memory/docs/sbrk/introduction/>
- <https://cs162.org/static/hw/hw-memory/docs/library-functions/introduction/>

Assignment goals
----------------

This homework focuses on user memory management. The official CS 162 memory
homework asks students to add `sbrk`-style heap growth to Pintos and implement
user-level allocation functions such as `malloc`, `calloc`, `realloc`, and
`free`. The repository also contains a standalone allocator practice directory,
`mm_alloc/`, which should be tested separately from the Pintos suite.

Key implementation areas
------------------------

- `mm_alloc/mm_alloc.c`: standalone `mm_malloc`, `mm_realloc`, and `mm_free`
  implementation.
- `mm_alloc/mm_test.c`: current smoke test for the standalone allocator.
- `pintos/src/userprog/` and related Pintos code: syscall and process memory
  behavior used by `sbrk`.
- `pintos/src/lib/user/`: user-level allocation library functions.
- `pintos/src/tests/memory/`: Pintos memory tests and expected-output checks.
- `pintos/src/tests/memory/Make.tests`: active Pintos memory test list.

Build and run
-------------

Standalone allocator:

```sh
cd hw-memory/mm_alloc
make
./mm_test
```

Pintos memory suite in the CS 162 Linux environment:

```sh
cd hw-memory/pintos/src/memory
make
make check
```

Run one Pintos memory test after the build directory exists:

```sh
cd hw-memory/pintos/src/memory/build
make tests/memory/malloc-simple.result
```

Current test inventory
----------------------

Coverage is mixed:

- `mm_alloc/mm_test.c` is a minimal smoke test for the standalone allocator.
- `pintos/src/tests/memory/Make.tests` enables 26 active Pintos memory tests.
- Active Pintos tests cover `sbrk`, heap growth, `malloc`, `free`, `realloc`,
  alignment, out-of-memory behavior, and several stress cases. `calloc` is part
  of the official allocator surface and should receive explicit extra tests.
- Stack-growth `.ck` files are present, but stack-growth test entries are
  commented out in `Make.tests`.

Completeness assessment
-----------------------

The Pintos memory test suite is the strongest coverage in the repository, but
the standalone allocator is under-tested. Also, Pintos tests must be run in the
course environment because they depend on the Pintos build system, emulator,
and expected 32-bit toolchain behavior.

Missing standalone allocator coverage includes:

- 8-byte alignment.
- Zero-size allocation policy.
- `calloc` zero initialization if `calloc` is part of the local API.
- `realloc(NULL, size)` and `realloc(ptr, 0)` behavior.
- Realloc growth and shrink copy preservation.
- Free-list reuse after `free`.
- Coalescing adjacent free blocks.
- Fragmentation stress.
- Invalid or repeated free behavior, if the assignment defines expectations.

Detailed missing-test prompts
-----------------------------

1. Expand `mm_alloc/mm_test.c` or add `mm_alloc/tests/mm_alloc_cases.c`:

   - Allocate 1, 2, 7, 8, 9, 16, 31, 64, 256, and 4096 bytes.
   - Assert every returned pointer is non-null when enough heap exists.
   - Assert `(uintptr_t)ptr % 8 == 0` for every allocation.
   - Fill every allocation with a byte pattern and verify no adjacent
     allocation is corrupted.

2. Add reuse-after-free coverage:

   ```c
   void *a = mm_malloc(64);
   void *b = mm_malloc(64);
   mm_free(a);
   void *c = mm_malloc(32);
   ```

   Assert `c` is valid and that writing to `c` does not corrupt `b`. If the
   allocator is expected to reuse free blocks, assert that behavior explicitly.

3. Add `realloc` growth coverage:

   - Allocate 32 bytes.
   - Fill bytes `0..31`.
   - Reallocate to 128 bytes.
   - Assert the first 32 bytes are preserved.
   - Write the new region to confirm it is usable.

4. Add `realloc` shrink coverage:

   - Allocate 128 bytes.
   - Fill a known pattern.
   - Reallocate to 16 bytes.
   - Assert the first 16 bytes are preserved.
   - Free the result.

5. Add `realloc` special-case coverage:

   - `mm_realloc(NULL, 64)` should behave like allocation if the API follows C
     `realloc`.
   - `mm_realloc(ptr, 0)` should follow the documented policy, usually freeing
     `ptr` and returning `NULL`.
   - Document the expected behavior if this assignment uses a different policy.

6. Add fragmentation coverage:

   - Allocate 100 small blocks.
   - Free every other block.
   - Allocate medium-size blocks.
   - Assert the allocator does not fail prematurely.
   - Free everything and repeat.

7. Add stress coverage:

   - Generate a deterministic sequence of allocate, free, and realloc
     operations.
   - Keep a shadow table of live blocks and expected byte patterns.
   - Verify all live blocks after every 50 operations.

8. Add sanitizer or Valgrind instructions:

   ```sh
   make clean
   CFLAGS="-g -O0 -fsanitize=address,undefined" make
   ./mm_test
   valgrind --leak-check=full ./mm_test
   ```

   Use whichever tool is available in the Linux environment.

9. Add a new Pintos memory test only when a behavior is not already covered:

   - Create `pintos/src/tests/memory/<name>.c`.
   - Create matching `pintos/src/tests/memory/<name>.ck`.
   - Add the test name to the appropriate list in `Make.tests`.
   - Run:

     ```sh
     cd pintos/src/memory
     make check
     cd build
     make tests/memory/<name>.result
     ```

10. Treat disabled stack-growth tests carefully:

    If stack growth is required for the current assignment version, uncomment
    the stack-growth entries in `Make.tests` and record the reason. If it is
    not required, leave them disabled and state that decision in the submission
    notes.

Suggested testing standard
--------------------------

Before considering this homework well tested, collect both signals:

- `mm_alloc` passes deterministic allocator unit tests and a stress run.
- Pintos `make check` passes the active memory tests in the course Linux
  environment.
