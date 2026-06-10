# HW 1: List

Official handout: <https://cs162.org/static/hw/hw-list/>

## Introduction

HW 1 introduces threads and processes from the perspective of a user-space
program. You will reuse the word-count problem from HW 0 and add two new
backends:

- `lwords` — word counting backed by the **Pintos intrusive list** API. This
  is the same `list.c` / `list.h` you will see later in the kernel projects.
- `pwords` — multi-threaded word counting that spawns one worker thread per
  input file and merges their results safely.

Both must produce the same final output as the reference `words` binary.

## Getting Started

```sh
cd ~/code/personal
git pull staff main
cd hw-list
make
```

`make` builds four executables:

| Binary    | Source you must finish                                   |
| --------- | -------------------------------------------------------- |
| `pthread` | `pthread.c` — small pthread practice program.            |
| `words`   | Reference single-threaded build (precompiled helpers).   |
| `lwords`  | `word_count_l.c` — list-backed `WordCount` storage.      |
| `pwords`  | `word_count_p.c`, `pwords.c` — thread-safe + driver.     |

You should **not** modify `list.h`, `list.c`, or `word_count.h`. The
precompiled `*.o` files in this directory implement the parts of HW 0 that
are reused; do not delete them.

## Tasks

### Pthread Practice

Finish `pthread.c` so `./pthread N` spawns `N` worker threads, prints each
thread's stack address relative to `main`'s, and joins every worker before
exiting. Use this exercise to convince yourself that stacks are per-thread and
the heap is shared.

### List-Backed Word Count

Implement `init_words`, `add_word`, `len_words`, `find_word`, and the
comparator inside `word_count_l.c`. The storage is a Pintos `struct list`
held inside each `WordCount`; use the list macros (`list_init`,
`list_push_back`, `list_entry`, `list_sort`, ...) rather than rolling your
own linked list.

When you run

```sh
./lwords gutenberg/alice.txt
./lwords gutenberg/alice.txt gutenberg/sawyer.txt
```

the output must match `./words` on the same inputs byte-for-byte.

### Threaded Word Count

In `word_count_p.c`, add a `pthread_mutex_t` (or equivalent) to `WordCount`
so multiple workers can call `add_word` on the same list without losing
updates. In `pwords.c`, spawn one thread per command-line file, have each
thread parse its file and update the shared structure, then `pthread_join`
every worker before printing the final tally.

`./pwords file1 file2` must equal `./words file1 file2` over repeated runs.

## Testing

```sh
make test
```

The default suite confirms the binaries link, `pthread` runs, and the
reference `words` binary still works on a small fixture. Comparison tests
that pit `lwords` and `pwords` against `words` are gated behind `RUN_FULL=1`
because they require your implementation:

```sh
RUN_FULL=1 make test
```

For concurrency stress, repeat the `pwords` invocation under a loop and use
`valgrind --tool=helgrind` to catch missing locks.

## Submission

Push to your personal repository; the autograder runs from `hw-list/`. The
official deliverable is the three sources you wrote (`word_count_l.c`,
`word_count_p.c`, `pwords.c`); do not commit binaries.

## Self-check

Before submitting, take a stab at these. Full answers in
[`STUDY.md`](STUDY.md).

- Why is an *intrusive* linked list (Pintos style) often preferred over a
  generic `std::list<T>`-style container?
- Sketch the exact interleaving by which two un-synchronized `add_word`
  callers can both insert the same key.
- Why does the autograder insist you not modify `list.h`, `list.c`, or
  `word_count.h`?
- Helgrind reports a race in `pwords` but the output looks correct. Should
  you fix it?

## References

- Official handout: <https://cs162.org/static/hw/hw-list/>
- pwords page: <https://cs162.org/static/hw/hw-list/docs/pwords/>
