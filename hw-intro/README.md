HW Intro
========

Overview
--------

This homework introduces C programming in a systems context. It includes small
programs for process limits and memory layout, plus a word-count exercise that
uses command-line flags, file input, and formatted output.

Key files
---------

- `Makefile`: builds the top-level `map` and `limits` programs.
- `limits.c`: reports resource-limit information.
- `map.c` and `recurse.c`: inspect stack, heap, and recursive call behavior.
- `words/Makefile`: builds the word-count executable.
- `words/main.c` and `words/word_count.c`: implement the word-count behavior.
- `words/gutenberg/`: larger manual input files for stress and sanity checks.

Build
-----

```sh
cd hw-intro
make

cd words
make
```

Local test plan
---------------

Run basic smoke checks for the top-level programs:

```sh
cd hw-intro
./limits
./map
```

Run the word-count executable against small and larger inputs:

```sh
cd hw-intro/words
./words -h
./words -c words.txt
./words -f words.txt
./words -c gutenberg/alice.txt
```

Test completeness review
------------------------

Current status: incomplete. The repository has build targets and sample input
files, but no automated test script or golden-output fixtures for this homework.
The commands above are smoke tests only.

What is currently covered:

- Compilation of `map`, `limits`, and `words`.
- Manual execution of resource-limit and memory-layout programs.
- Manual word-count execution on one small file and larger Gutenberg files.

Important gaps:

- No automated assertion that `limits` reports real `getrlimit` values instead
  of placeholder values.
- No automated assertion for expected `map` output shape.
- No golden-output tests for word totals, word-frequency output, stdin input,
  multiple input files, empty files, punctuation, capitalization, or invalid
  flags.

Recommended missing tests
-------------------------

- Add a small `tests/` directory with fixed input files and expected outputs.
- Add a `make test` target that rebuilds and compares `./words` output with
  checked-in golden files.
- Add stdin coverage, for example `printf "one two one\n" | ./words -f`.
- Add negative tests for bad flags and missing files.
- Add a limit sanity test that fails if all reported values remain zero.
