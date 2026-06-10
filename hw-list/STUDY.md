# HW 1: Understanding Check

Self-check questions for HW 1. Written by the maintainers of this repo,
not the CS 162 staff. Try to answer in your own words first.

## 1. The Pintos `list` is *intrusive* — the link node lives inside the data structure, not in a separate wrapper. What does that buy you compared with a `std::list<T>`-style external linked list?

<details><summary>Answer</summary>

Intrusive lists give you O(1) removal of an element when you already hold
a pointer to it (no scan to find the enclosing node), zero allocation for
the link itself, and the same node can sit in multiple lists by including
multiple `struct list_elem` fields. The cost is that the element type has
to be aware of the list — you can't store an arbitrary value, only types
you control. Pintos uses this everywhere in the kernel because it cannot
rely on `malloc` in interrupt context.

</details>

## 2. `pwords` spawns one thread per input file. Why is that better than reusing a small worker pool when the file count is modest, and why does the trade-off flip when the file count is large?

<details><summary>Answer</summary>

For a handful of files, the cost of `pthread_create` is dwarfed by the I/O
each thread performs, and the code stays simple (no queue, no
load-balancing). When you have thousands of files, you pay thread-creation
overhead on every one, you exhaust file-descriptor limits, and the kernel
scheduler spends more time switching between threads than the workers
spend reading. A bounded thread pool with a work queue (your `wq_t` from
HW 3) amortizes both costs.

</details>

## 3. Suppose two threads call `add_word(wclist, "hello")` at the same time and "hello" is not yet in the list. Without a lock, describe one specific interleaving that loses an update.

<details><summary>Answer</summary>

Thread A calls `find_word("hello")` → returns `NULL`. Thread B calls
`find_word("hello")` → also returns `NULL` (the list is unchanged).
Thread A allocates a `WordCount{word="hello", count=1}` and links it.
Thread B allocates a *second* `WordCount{word="hello", count=1}` and links
it. Now the list has two entries for "hello" with count 1 each instead of
one entry with count 2 — the second `add_word` lost the increment. Wrap
the find+insert+increment in a single critical section.

</details>

## 4. Why does the assignment ask you to put a `pthread_mutex_t` inside `WordCount` itself instead of one global mutex around the whole list?

<details><summary>Answer</summary>

A global lock serializes all word inserts; a per-word lock would let
threads incrementing different words proceed in parallel. In practice the
HW 1 input sizes are small enough that the global mutex is the simpler,
correct choice and you will not see contention; the per-element lock is
the *conceptual* lesson — fine-grained locking exists, and you need to
understand which invariants each lock protects.

</details>

## 5. If you forget to `pthread_join` a worker thread in `pwords`, what symptom appears first: wrong output, a crash, or a leak?

<details><summary>Answer</summary>

Usually wrong output. Without `join`, `main` proceeds to print the merged
counts before some workers have finished updating the shared list — so the
totals are short. Depending on timing you may also see a SIGSEGV when
main destroys the list while a worker still references it, or a memory
leak in the worker's thread-local storage. The deterministic failure mode
is the wrong totals.

</details>

## 6. The handout tells you not to modify `list.h`, `list.c`, or `word_count.h`. Why does the autograder care about this even if your code passes the tests?

<details><summary>Answer</summary>

Those files define the *contract* the grading harness compiles and links
against. The grader builds your `word_count_l.o` against the staff
`list.o`; if you have changed the function signatures in `list.h` your
object file links but the staff harness gets surprises. Keeping the
headers fixed also means the staff can swap in a known-good
implementation to isolate bugs in your code from bugs in your list usage.

</details>

## 7. `valgrind --tool=helgrind` flags a "data race" on your `pwords` even though the output is always correct. Should you fix it?

<details><summary>Answer</summary>

Yes. Helgrind reports races based on happens-before, not on whether the
race produces wrong output today. A race that "looks correct" still has
undefined behavior under the C memory model and will start producing wrong
answers under a different optimization level, CPU, or thread count. Add
the missing synchronization (or document a memory-order argument for why
the access is safe — atomics, not racy plain reads).

</details>
