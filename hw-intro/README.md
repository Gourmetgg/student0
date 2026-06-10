# HW 0: Intro

Official handout: <https://cs162.org/static/hw/hw-intro/>

## Introduction

This semester you will use a number of tools to submit, build, and debug your
code. HW 0 is the CS 162 warm-up: it gets you comfortable with the course
workspace, the C toolchain, GDB, and a small word-count program. Each later
homework assumes you can navigate this stack without help, so it is worth
finishing every section even if some pieces feel familiar.

## Getting Started

Clone your repository inside the CS 162 workspace and pull the staff starter
code:

```sh
cd ~/code/personal
git pull staff main
cd hw-intro
```

The directory contains three independent pieces:

| Path        | What you edit                                            |
| ----------- | -------------------------------------------------------- |
| `limits.c`  | Print the calling process's resource limits.             |
| `map.c`     | Print where stack, heap, globals, and text live.         |
| `recurse.c` | Helper for `map.c` to observe stack growth.              |
| `words/`    | Word-count program built on `word_count.h`.              |

Build the top-level binaries from `hw-intro/`:

```sh
make            # builds ./limits and ./map
./limits
./map
```

Build the word-count program from `hw-intro/words/`:

```sh
cd words
make
./words -c words.txt
./words -f words.txt
```

## Tasks

### Counting Words

Implement `num_words`, `count_words`, and the supporting helpers in
`words/word_count.c`. Finish `words/main.c` so the program supports:

- `-c, --count` — print the total number of words.
- `-f, --frequency` — print each unique word and its count.
- `-h, --help` — usage information.
- One or more file arguments, or stdin when no file is supplied.

Free every `WordCount` you allocate. The program must not leak memory under
`valgrind`.

### User Limits

In `limits.c`, use `getrlimit` to print the stack size, process limit, and
maximum number of open file descriptors. The output should be human-readable.

### From Source Code to Executable

Read the `map.c` / `recurse.c` pair and add print statements that show, for the
running process, the addresses of:

- the call stack at multiple recursion depths,
- the heap (via `malloc`),
- a global variable in `.data`,
- a function in `.text`.

### GDB Basics

Step through `map` under `gdb` and confirm you can set breakpoints, inspect
locals, and follow the stack across `recurse` invocations. There is no code to
turn in here, but you will need these reflexes for every later assignment.

## Testing

Run the smoke tests from `hw-intro/`:

```sh
make test
```

The default suite confirms that `limits` and `map` build and print plausible
output. The `words` program is not part of the default suite because the
starter does not compile until you implement the word-count helpers. Once your
implementation builds, run the fuller suite:

```sh
RUN_FULL=1 make test
```

Add fixtures to `tests/fixtures/` and extend `tests/run.sh` with new
assertions as you cover more behavior (empty input, punctuation, multi-file,
stdin, missing files).

## Submission

Push your work to your personal repository. The autograder is wired up via
GitHub Actions; see the [Submission section of the official
handout](https://cs162.org/static/hw/hw-intro/docs/submission/) for the
current submission URL and deadline.

## Self-check

Before submitting, take a stab at these. Full answers in
[`STUDY.md`](STUDY.md).

- Why does the starter `main.c` deliberately fail to build under
  `-Werror=unused-but-set-variable`?
- Why is `count_words` documented to return `1` on error when `main` returns
  `0` on success?
- What runtime feature makes the addresses printed by `./map` change every
  invocation, and what flag stabilizes them?
- Why do you have to lower-case each character *before* `add_word`, not
  after?

## References

- Official handout: <https://cs162.org/static/hw/hw-intro/>
- Counting Words page: <https://cs162.org/static/hw/hw-intro/docs/counting-words/>
