# HW 4: Memory

Official handout: <https://cs162.org/static/hw/hw-memory/>

## Introduction

The Pintos user-space, as shipped, has no way to allocate dynamic memory in a
user program. In HW 4 you fix that. You will add an `sbrk` system call to
Pintos so user programs can request additional heap pages, then implement
user-level `malloc`, `calloc`, `realloc`, and `free` on top of it. A
companion standalone exercise in `mm_alloc/` builds the same allocator
without Pintos so you can develop and test it in isolation.

## Getting Started

```sh
cd ~/code/personal
git pull staff main
cd hw-memory
```

The repository has two pieces:

| Path        | Scope                                                      |
| ----------- | ---------------------------------------------------------- |
| `mm_alloc/` | Standalone allocator built into a shared library.          |
| `pintos/`   | Full Pintos tree; you will edit `userprog/`, `lib/user/`. |

Build the standalone allocator first because it has the shortest feedback
loop:

```sh
cd mm_alloc
make           # builds hw3lib.so and mm_test
./mm_test
```

Pintos work happens under `pintos/src/`. The memory tests live in
`pintos/src/tests/memory/` and the suite is enabled in `Make.tests`.

## Tasks

### sbrk

Add a new system call number, wire it through `syscall_handler`, and
implement `sys_sbrk(intptr_t increment)`. Growing the heap allocates new
user pages and installs them into the page table; shrinking deallocates the
trailing pages. Return the previous program break on success and
`(void*) -1` on failure.

Cover at least: a positive `increment` returns the old break, a zero
`increment` returns the current break, a negative `increment` truncates the
heap, and a failed allocation does not partially commit pages.

### Library Functions

Implement user-space `malloc`, `calloc`, `realloc`, and `free` in
`pintos/src/lib/user/`. Use `sbrk` to request memory from the kernel; manage
free blocks yourself with a free list or boundary tags. Honor alignment
requirements and zero memory in `calloc`.

### Standalone allocator (mm_alloc)

`mm_alloc/mm_alloc.c` is the same allocator without Pintos in the loop.
Implement `mm_malloc`, `mm_realloc`, and `mm_free` directly on top of the
host `sbrk` and verify against `mm_test`. The standalone version is the
fastest way to debug bookkeeping bugs.

## Testing

### Standalone

```sh
cd mm_alloc
make test
```

On the unmodified starter, the build fails under `-Werror=unused-parameter`
and the test reports `SKIP`. After your implementation compiles, `make test`
builds and runs `mm_test`. Extend `mm_test.c` with assertions for `mm_malloc(0)`,
alignment, writing every allocated byte, `mm_free(NULL)`, reuse after free,
realloc grow/shrink, and many small allocations.

### Pintos

Pintos tests require the CS 162 i386 toolchain and QEMU. They are **not**
run by `make test` because those tools are not present on every machine.
Inside the course Docker workspace:

```sh
cd pintos/src/memory
make
make check
```

The active list (`Make.tests`) covers 26 memory tests including `sc-bad-arg`,
`mm-anonymous-page`, `mm-bad-ptr`, `mm-vaddr`, allocator regression tests,
and the `mm_alloc` integration tests.

## Submission

Push `hw-memory/` to your personal repository. The autograder runs the full
Pintos memory suite. See the [Submission
section](https://cs162.org/static/hw/hw-memory/docs/submission/) for the
deadline and grading split.

## Self-check

Before submitting, take a stab at these. Full answers in
[`STUDY.md`](STUDY.md).

- Why is `sbrk(0)` worth optimizing as a fast no-op?
- A user `sbrk(4096)` returns a valid pointer, but writing to it faults.
  What did the kernel forget to do?
- Why is *coalescing* on `free` essential, and what symptom appears if you
  skip it?
- `calloc(n, size)` is not equivalent to `malloc(n*size)` plus `memset`.
  Why?

## References

- Official handout: <https://cs162.org/static/hw/hw-memory/>
- sbrk introduction: <https://cs162.org/static/hw/hw-memory/docs/sbrk/introduction/>
- Library functions: <https://cs162.org/static/hw/hw-memory/docs/library-functions/introduction/>
