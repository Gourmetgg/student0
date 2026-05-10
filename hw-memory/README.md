HW Memory
=========

Overview
--------

This homework has two memory-focused parts: a standalone allocator exercise in
`mm_alloc/` and a Pintos memory project under `pintos/`.

Key files
---------

- `mm_alloc/Makefile`: builds `hw3lib.so` and `mm_test`.
- `mm_alloc/mm_alloc.c`: implements `mm_malloc`, `mm_realloc`, and `mm_free`.
- `mm_alloc/mm_test.c`: minimal dynamic-loading smoke test for the allocator.
- `pintos/src/memory/Makefile`: entry point for the Pintos memory test suite.
- `pintos/src/tests/memory/Make.tests`: declares the active Pintos memory tests.
- `pintos/src/tests/memory/*.c` and `*.ck`: Pintos memory test cases and checks.

Build
-----

Build the standalone allocator:

```sh
cd hw-memory/mm_alloc
make
```

Build the Pintos memory project in the course environment:

```sh
cd hw-memory/pintos/src/memory
make
```

Local test plan
---------------

Run the standalone allocator smoke test:

```sh
cd hw-memory/mm_alloc
./mm_test
```

Run the Pintos memory suite:

```sh
cd hw-memory/pintos/src/memory
make check
```

Run a single Pintos test after the build directory exists:

```sh
cd hw-memory/pintos/src/memory/build
make tests/memory/malloc-simple.result
```

Test completeness review
------------------------

Current status: mixed. The standalone allocator has only a minimal smoke test.
The Pintos memory project has the strongest test harness in the repository.

What is currently covered:

- `mm_test` verifies that the allocator functions can be loaded and used for a
  very small allocation path.
- `pintos/src/tests/memory/Make.tests` enables 26 active Pintos memory tests.
- Active Pintos coverage includes `sbrk`, `malloc`, and `realloc` behavior.
- Additional stack-growth `.ck` files are present, but the stack-growth group is
  commented out in `Make.tests`.

Important gaps:

- `mm_test` does not cover alignment, many allocation sizes, realloc growth and
  shrink behavior, coalescing, fragmentation, double-free resilience, or stress
  behavior.
- Pintos tests require the course Linux environment, 32-bit toolchain, and QEMU.
- The disabled stack-growth tests are not part of `make check` unless the
  Makefile is updated intentionally.

Recommended missing tests
-------------------------

- Add allocator unit tests for zero-size allocation, alignment, reuse after
  free, realloc copy preservation, large allocations, and randomized stress.
- Add a memory-check workflow with Valgrind or sanitizers where available.
- Keep the Pintos `make check` output as the main functional signal for the
  Pintos part.
- Document any intentionally disabled Pintos tests before enabling them.
