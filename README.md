CS 162 Student Repository
=========================

This repository contains code for CS 162 individual assignments.

Homework documentation
----------------------

Each homework directory has its own English README with an assignment-style
overview, key files, build commands, local test commands, and a test
completeness review.

- [`hw-intro`](hw-intro/README.md): C basics, process limits, memory layout, and word count.
- [`hw-list`](hw-list/README.md): Pintos lists, word count data structures, and pthread word count.
- [`hw-shell`](hw-shell/README.md): A small Unix-style shell and tokenizer.
- [`hw-memory`](hw-memory/README.md): Standalone allocator practice plus Pintos memory tests.
- [`hw-map-reduce`](hw-map-reduce/README.md): C MapReduce coordinator, worker, client, and applications.
- [`hw-map-reduce-rs`](hw-map-reduce-rs/README.md): Rust MapReduce coordinator, worker, client, and applications.
- [`hw-http`](hw-http/README.md): C HTTP file server, proxy path, and concurrency variants.
- [`hw-http-rs`](hw-http-rs/README.md): Rust HTTP server helpers, server logic, and statistics.

Testing audit summary
---------------------

This audit is based on the repository contents. The local Windows environment
used for this documentation did not have `make`, `cargo`, or a configured WSL
Linux distribution, so the tests were not executed end-to-end here. Run the
commands from a Linux, WSL, or course VM environment with the assignment
dependencies installed.

The current test coverage is not complete for most homework directories:

- Strongest local harness: `hw-memory/pintos/src/tests/memory` defines 26 active
  Pintos memory tests through `Make.tests`. Additional `.ck` files exist, but
  the stack-growth group is currently commented out in that Makefile.
- Partial helper-level coverage: `hw-http-rs` has 12 Rust tests for argument
  defaults, MIME type mapping, response-header helpers, and statistics helpers.
  It still needs full server integration and concurrency tests.
- Smoke-test coverage only: `hw-shell/test.sh` checks one built-in command and
  one external command. `hw-memory/mm_alloc/mm_test.c` is a minimal allocator
  smoke test.
- No automated local test harness found: `hw-intro`, `hw-list`,
  `hw-map-reduce`, and `hw-http` rely on manual commands or comparison against
  expected behavior.
- Unfinished ignored test: `hw-map-reduce-rs/src/tests/mod.rs` contains an
  ignored `test_wc` with a `todo!` placeholder for the input file.

Use the per-homework READMEs as the source of truth for what is currently
covered, what is missing, and what should be added before considering each
homework well tested.
