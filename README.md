CS 162 Student Repository
=========================

This repository contains code for the CS 162 individual homework assignments.
The documentation in each homework directory is written in an assignment-report
style and aligned with the public CS 162 homework pages.

Documentation index
-------------------

- [`hw-intro`](hw-intro/README.md): HW 0, C tools, user limits, memory layout,
  GDB basics, and word counting.
- [`hw-list`](hw-list/README.md): HW 1, Pintos lists, pthread practice, and
  threaded word counting.
- [`hw-shell`](hw-shell/README.md): HW 2, directory commands, program
  execution, path resolution, redirection, pipes, and signal handling.
- [`hw-http`](hw-http/README.md): HW 3 C HTTP server, socket setup, GET
  handling, proxying, server variants, and performance.
- [`hw-http-rs`](hw-http-rs/README.md): HW 3 Rust HTTP server, socket handling,
  GET parsing, directory responses, and statistics.
- [`hw-memory`](hw-memory/README.md): HW 4, Pintos `sbrk`, user heap growth,
  and user-space allocation library functions.
- [`hw-map-reduce`](hw-map-reduce/README.md): HW 5 C MapReduce coordinator,
  worker, client, task scheduling, and fault tolerance.
- [`hw-map-reduce-rs`](hw-map-reduce-rs/README.md): HW 5 Rust MapReduce
  coordinator, worker registration, task distribution, and fault tolerance.

Source alignment
----------------

The homework summaries and test expectations are based on the current public
CS 162 pages:

- <https://cs162.org/static/hw/hw-intro/>
- <https://cs162.org/static/hw/hw-list/>
- <https://cs162.org/static/hw/hw-shell/>
- <https://cs162.org/static/hw/hw-http/>
- <https://cs162.org/static/hw/hw-http-rs/>
- <https://cs162.org/static/hw/hw-memory/>
- <https://cs162.org/static/hw/hw-map-reduce/>
- <https://cs162.org/static/hw/hw-map-reduce-rs/>

Repository-wide test audit
--------------------------

This repository does not currently have complete local automated testing for
every homework. The audit below describes the state of the repository, not the
official course autograder. The local Windows environment used for this audit
did not have `make`, `cargo`, or a configured WSL Linux distribution, so tests
were not executed end-to-end here. Run the listed commands in Linux, WSL, or
the CS 162 course environment.

Current coverage:

- `hw-memory/pintos/src/tests/memory/Make.tests` is the strongest test suite in
  this repository. It enables 26 active Pintos memory tests covering `sbrk`,
  `malloc`, `free`, and `realloc` behavior. `calloc` still deserves explicit
  additional coverage.
- `hw-http-rs/src/tests/` has helper-level Rust tests for argument defaults,
  MIME type helpers, response helpers, and statistics.
- `hw-shell/test.sh` is a small smoke test for one built-in command and one
  external command.
- `hw-memory/mm_alloc/mm_test.c` is a minimal allocator smoke test.
- `hw-map-reduce-rs/src/tests/mod.rs` contains an ignored `test_wc` with a
  placeholder input path, so default `cargo test` does not validate a full
  MapReduce run.

Major missing coverage:

- `hw-intro`, `hw-list`, `hw-http`, and `hw-map-reduce` need checked-in test
  harnesses with deterministic fixtures and golden outputs.
- `hw-shell` needs tests for the full CS 162 shell surface: `cd`, `pwd`,
  external program execution, path resolution, redirection, pipes, Ctrl-D,
  Ctrl-C, and Ctrl-Z behavior.
- `hw-http` and `hw-http-rs` need real server integration tests that send HTTP
  requests over sockets and assert status lines, headers, bodies, directory
  responses, malformed requests, and concurrent clients.
- `hw-map-reduce` and `hw-map-reduce-rs` need integration tests that start a
  coordinator, start workers, submit jobs, compare output to golden files, and
  validate retry behavior after worker failure.

Each homework README gives detailed prompts for the exact tests that should be
added next.
