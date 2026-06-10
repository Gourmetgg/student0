# HW 4: Understanding Check

Self-check questions for HW 4. Written by the maintainers of this repo,
not the CS 162 staff.

## 1. Why does Pintos need a kernel-level `sbrk` syscall — couldn't the user program just `mmap` a big region and call `malloc` itself?

<details><summary>Answer</summary>

The stock Pintos user-space has no `mmap` either. There is no virtual
memory subsystem that lets a user process request additional pages; the
loader places the binary, sets up an initial heap, and that is the entire
addressable region. `sbrk` is the smallest possible primitive: it asks
the kernel to install one or more new user pages above the current break
and return the previous break. User-space `malloc` is then a normal
boundary-tag or free-list allocator built on top.

</details>

## 2. Your `sbrk(0)` returns the current break without changing it. Why must that operation be cheap, and what library function relies on it being correct?

<details><summary>Answer</summary>

`malloc` calls `sbrk(0)` (or its equivalent) at startup to learn where the
heap begins. It is called every time the allocator decides whether to
extend the heap with another `sbrk(positive)`. If `sbrk(0)` were a slow
or page-table-modifying operation, `malloc` performance would collapse.
Make sure your kernel implementation early-returns when `increment ==
0` without touching the page table.

</details>

## 3. A user program calls `sbrk(4096)` and then writes to the returned address. The write faults. What kernel bug does that point to?

<details><summary>Answer</summary>

You allocated the page frame but did not *install* it in the page table
of the calling process — `pagedir_set_page` (or your project's
equivalent) was skipped. The user write triggers a page fault, the
exception handler does not find a mapping for that address, and Pintos
kills the process. The fix is to install every new frame with the
correct `writable=true` flag and a fresh user-pool page.

</details>

## 4. Your user `malloc` uses a free list. Why is *coalescing* adjacent free blocks essential, and what symptom does forgetting it produce?

<details><summary>Answer</summary>

Without coalescing, a sequence of `malloc(16); free; malloc(16); free; ...`
fragments the heap into many small free blocks. A subsequent
`malloc(128)` cannot fit in any single fragment and has to call `sbrk`
for more memory — even though the total free bytes far exceed 128. The
heap grows without bound. Coalescing merges adjacent free blocks on
`free` (or lazily on the next `malloc`) so the largest available block
grows as memory is returned.

</details>

## 5. `realloc(ptr, new_size)` is allowed to *move* the allocation. What is the contract for the *contents* between the old and new pointer?

<details><summary>Answer</summary>

The first `min(old_size, new_size)` bytes are preserved; bytes past the
old size are uninitialized (for grow) and gone (for shrink). If `realloc`
returns a new pointer, the old pointer is freed and must not be
dereferenced. If `realloc` returns `NULL` on failure, the *old* allocation
remains valid — a classic bug is `p = realloc(p, big)` where a failure
leaks the old `p`. The correct pattern is `tmp = realloc(p, big); if
(tmp) p = tmp;`.

</details>

## 6. `calloc(n, size)` zeros memory. Why is it not equivalent to `malloc(n*size); memset(0)`?

<details><summary>Answer</summary>

Two reasons. First, `calloc` checks for integer overflow on `n * size`;
the naive version silently wraps and allocates a tiny block, after which
the `memset` writes past the end. Second, a high-quality `calloc` can
skip the `memset` for newly-mapped pages because the kernel hands them
out zeroed already — turning an O(size) operation into O(1). Even
Pintos's simple allocator can take advantage of zero-on-allocation
behavior of `sbrk`.

</details>

## 7. The Pintos `Make.tests` enables 26 memory tests. Some of them deliberately pass *bad* pointers to the kernel. Why is exercising the failure paths just as important as the success paths?

<details><summary>Answer</summary>

Kernel code that is correct on valid input but corrupts state on invalid
input is *worse* than code that is broken on both: it ships, looks fine
in normal use, and is the entry point for security exploits. The
`sc-bad-arg`, `mm-bad-ptr`, and `mm-vaddr` tests confirm that your
syscall handler refuses to dereference unmapped user pointers, returns
`-1` cleanly, and does not leak kernel memory or panic. The course
graders weight these heavily because production OSes live or die by
their boundary checks.

</details>
