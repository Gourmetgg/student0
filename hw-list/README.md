HW List
=======

Overview
--------

This homework practices linked-list data structures and threaded word counting.
It compares a reference word-count implementation with Pintos-list and pthread
implementations.

Key files
---------

- `Makefile`: builds `pthread`, `words`, `lwords`, and `pwords`.
- `list.c` and `list.h`: Pintos list implementation.
- `word_count_l.c`: list-backed word-count implementation.
- `word_count_p.c`: pthread-aware word-count implementation.
- `pwords.c`: runs one word-count worker per input file.
- `gutenberg/`: larger input files for comparison and stress checks.

Build
-----

```sh
cd hw-list
make
```

Local test plan
---------------

Run the pthread demo:

```sh
./pthread 4
```

Compare all word-count executables on the same input:

```sh
./words gutenberg/alice.txt > /tmp/words.out
./lwords gutenberg/alice.txt > /tmp/lwords.out
./pwords gutenberg/alice.txt > /tmp/pwords.out
diff -u /tmp/words.out /tmp/lwords.out
diff -u /tmp/words.out /tmp/pwords.out
```

Test multiple input files for the threaded implementation:

```sh
./pwords gutenberg/alice.txt gutenberg/sawyer.txt gutenberg/time.txt
```

Test completeness review
------------------------

Current status: incomplete. The repository has build targets and reference
object files, but no automated test target or checked-in expected outputs.

What is currently covered:

- Compilation of all four executables.
- Manual comparison between reference, list-backed, and pthread-backed word
  count outputs.
- Manual pthread demo execution.

Important gaps:

- No `make test` target.
- No automated comparison for empty files, repeated words, punctuation,
  uppercase/lowercase behavior, stdin input, or multiple files.
- No automated race or stress test for `pwords`.
- No memory-check target for leaks or invalid list ownership.

Recommended missing tests
-------------------------

- Add deterministic fixtures and golden outputs for `words`, `lwords`, and
  `pwords`.
- Add a script that compares `lwords` and `pwords` against the reference
  executable for every fixture.
- Add a multi-file stress test that runs `pwords` repeatedly.
- Add optional sanitizer or Valgrind instructions for list and thread safety.
