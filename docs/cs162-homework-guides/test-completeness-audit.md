CS 162 Homework Test Completeness Audit
=======================================

Audit date: 2026-05-10

Scope
-----

This report validates the homework documentation and the current testing state
of this repository. It is based on the public CS 162 homework pages, the files
in this repository, and the commands that could be attempted in the local
Windows environment.

Official sources used:

- <https://cs162.org/static/hw/hw-intro/>
- <https://cs162.org/static/hw/hw-list/>
- <https://cs162.org/static/hw/hw-shell/>
- <https://cs162.org/static/hw/hw-http/>
- <https://cs162.org/static/hw/hw-http-rs/>
- <https://cs162.org/static/hw/hw-memory/>
- <https://cs162.org/static/hw/hw-map-reduce/>
- <https://cs162.org/static/hw/hw-map-reduce-rs/>

Environment validation
----------------------

The local environment is useful for static review, but it is not sufficient for
full CS 162 execution testing.

Attempted commands:

| Check | Result | Impact |
| --- | --- | --- |
| `make --version` | Blocked: `make` is not installed | C homework builds and Pintos tests cannot be executed locally. |
| `cargo --version` | Blocked: `cargo` is not installed | Rust homework tests cannot be executed locally. |
| `bash -lc "uname -a"` | Blocked: WSL reports no installed Linux distribution | Linux shell scripts and Unix signal tests cannot be executed locally. |
| `rg -n "TODO|todo!" ...` | Passed | Static implementation gaps were found and recorded below. |
| `rg -n "[\\p{Han}]" README.md hw-*/README.md` | Passed earlier | Repository homework documentation is English-only. |
| `git diff --check` | Passed earlier | Markdown files do not contain whitespace errors. |

Static evidence summary
-----------------------

The repository is not ready to be called fully tested. Static inspection found
53 `TODO` or `todo!` markers across homework code and documentation. The most
important markers are implementation placeholders, not just comments.

Observed implementation gap counts by homework:

| Homework | Static TODO markers | Interpretation |
| --- | ---: | --- |
| `hw-intro` | 0 | No obvious placeholder markers, but no automated tests were found. |
| `hw-list` | 13 | List and pthread word-count code still has visible TODO markers. |
| `hw-shell` | 0 | No TODO markers, but the test harness is only a smoke test. |
| `hw-http` | 15 | The C HTTP server still has several part-level TODO markers. |
| `hw-http-rs` | 6 | The Rust HTTP server still has `todo!` placeholders in core modules. |
| `hw-memory` | 3 | The standalone allocator has unimplemented allocation functions. |
| `hw-map-reduce` | 6 | The C coordinator has visible TODO markers. |
| `hw-map-reduce-rs` | 10 | The Rust coordinator and ignored test still contain placeholders. |

Existing test inventory
-----------------------

| Homework | Existing tests or harness | Completeness verdict |
| --- | --- | --- |
| `hw-intro` | No checked-in automated harness found | Not complete |
| `hw-list` | No checked-in automated harness found | Not complete |
| `hw-shell` | `test.sh` checks one `pwd` case and one `/bin/ls` case | Not complete |
| `hw-http` | No checked-in automated HTTP harness found | Not complete |
| `hw-http-rs` | 12 helper-level Rust tests in `src/tests` | Partial, not complete |
| `hw-memory` | `mm_alloc/mm_test.c`; 26 active Pintos memory tests in `Make.tests` | Partial; Pintos side is strongest, standalone allocator is not complete |
| `hw-map-reduce` | No checked-in automated cluster harness found | Not complete |
| `hw-map-reduce-rs` | One ignored `test_wc` containing `todo!("Pick an input file")` | Not complete |

Homework-by-homework validation
-------------------------------

### HW 0: Intro

Local execution status: blocked by missing `make`.

Documentation correctness check:

- The README points to the correct official HW 0 page and counting-words task.
- The listed files match the repository structure.
- The missing-test prompts cover word totals, frequency output, stdin,
  multiple files, invalid flags, `limits`, and `map` output shape.

Completeness verdict: not complete.

Required next tests:

- Add a `words/tests/` fixture directory.
- Add golden-output tests for `./words -c` and `./words -f`.
- Add stdin and multi-file tests.
- Add shape checks for `limits` and `map`.

Minimum command set to run in Linux or WSL:

```sh
cd hw-intro
make
./limits
./map
cd words
make
./words -c tests/basic.txt
./words -f tests/basic.txt
```

### HW 1: Lists

Local execution status: blocked by missing `make`.

Static evidence:

- `word_count_l.c`, `word_count_p.c`, and `pwords.c` still contain TODO
  markers.

Documentation correctness check:

- The README maps the official list and `pwords` tasks to `list.c`,
  `word_count_l.c`, `word_count_p.c`, and `pwords.c`.
- The recommended tests compare `words`, `lwords`, and `pwords`, which is the
  right local strategy for this homework.

Completeness verdict: not complete.

Required next tests:

- Add deterministic word-count fixtures.
- Compare `lwords` and `pwords` against the reference `words` binary.
- Add a repeated `pwords` race test.
- Add memory-check instructions with Valgrind or sanitizers.

Minimum command set to run in Linux or WSL:

```sh
cd hw-list
make
./words tests/fixtures/single.txt > /tmp/ref.out
./lwords tests/fixtures/single.txt > /tmp/lwords.out
./pwords tests/fixtures/single.txt > /tmp/pwords.out
diff -u /tmp/ref.out /tmp/lwords.out
diff -u /tmp/ref.out /tmp/pwords.out
```

### HW 2: Shell

Local execution status: blocked by missing `make` and unavailable WSL Linux
environment.

Static evidence:

- `test.sh` exists and is readable.
- It currently checks only `pwd` and `/bin/ls`.

Documentation correctness check:

- The README covers the official shell surfaces: directory commands,
  foreground execution, redirection, pipes, Ctrl-D, Ctrl-C, and Ctrl-Z.
- The missing-test prompts include both deterministic command tests and
  environment-sensitive signal tests.

Completeness verdict: not complete.

Required next tests:

- Expand `test.sh` into a table-driven harness.
- Add `cd`, invalid command, redirection, pipe, and tokenizer tests.
- Add Linux-only signal tests for Ctrl-C and Ctrl-Z behavior.

Minimum command set to run in Linux or WSL:

```sh
cd hw-shell
make
bash test.sh
printf "cd /\npwd\n" | ./shell
printf "echo hello | wc -w\n" | ./shell
```

### HW 3: HTTP Server in C

Local execution status: blocked by missing `make`.

Static evidence:

- `httpserver.c` contains part-level TODO markers for file serving, directory
  serving, proxying, and concurrency paths.
- No checked-in HTTP integration test script was found.

Documentation correctness check:

- The README maps the official socket and HTTP tasks to `httpserver.c`,
  `libhttp.c`, `wq.c`, and the server variants.
- The missing-test prompts require real socket tests, not just unit tests.

Completeness verdict: not complete.

Required next tests:

- Add `tests/http_smoke.sh`.
- Run it against `httpserver`, `forkserver`, `threadserver`, and `poolserver`.
- Add status, header, body, directory, traversal, malformed request, proxy, and
  concurrency checks.

Minimum command set to run in Linux or WSL:

```sh
cd hw-http
make
./httpserver --files www --port 8000
curl -i http://127.0.0.1:8000/
curl -i http://127.0.0.1:8000/not-found
```

### HW 3: HTTP Server in Rust

Local execution status: blocked by missing `cargo`.

Static evidence:

- `src/http.rs`, `src/server.rs`, and `src/stats.rs` contain `todo!`
  placeholders.
- `src/tests` contains 12 helper-level tests.
- No integration test starts the real server and sends TCP requests.

Documentation correctness check:

- The README correctly separates helper-level testing from socket-level
  integration testing.
- The missing-test prompts call for parser tests, real `GET` tests, directory
  tests, stats integration checks, and concurrent client coverage.

Completeness verdict: partial, not complete.

Required next tests:

- Keep current helper tests.
- Add `tests/server_integration.rs`.
- Add request parser coverage and real TCP client tests.
- Verify stats after real requests.

Minimum command set to run in Linux, WSL, or a Rust environment:

```sh
cd hw-http-rs
cargo test
cargo test --test server_integration
cargo run -- --files www --port 8000
```

### HW 4: Memory

Local execution status: blocked by missing `make` and unavailable Pintos Linux
environment.

Static evidence:

- `mm_alloc/mm_alloc.c` contains TODO markers for malloc, realloc, and free.
- `pintos/src/tests/memory/Make.tests` enables 26 active memory tests.
- Stack-growth tests are present but commented out.

Documentation correctness check:

- The README correctly distinguishes the standalone allocator from the Pintos
  memory suite.
- It avoids claiming active `calloc` coverage where the current active memory
  test list does not show explicit `calloc` tests.

Completeness verdict: partial, not complete.

Required next tests:

- Expand standalone allocator tests for alignment, reuse, realloc growth and
  shrink, fragmentation, and stress.
- Run Pintos `make check` in the course environment.
- Decide whether stack-growth tests are required for the target assignment
  version before enabling them.

Minimum command set to run in Linux or the course VM:

```sh
cd hw-memory/mm_alloc
make
./mm_test

cd ../pintos/src/memory
make
make check
```

### HW 5: MapReduce in C

Local execution status: blocked by missing `make`.

Static evidence:

- The C coordinator contains TODO markers.
- No checked-in integration harness was found.

Documentation correctness check:

- The README maps the official job-submission and cluster behavior to the RPC,
  coordinator, worker, client, and app directories.
- The missing-test prompts require a real cluster test with cleanup and golden
  output comparison.

Completeness verdict: not complete.

Required next tests:

- Add `tests/run_cluster_test.sh`.
- Start coordinator and workers automatically.
- Submit `wc`, `grep`, and `vertex_degree` jobs.
- Compare processed output against golden files.
- Add worker-failure retry coverage.

Minimum command set to run in Linux or WSL:

```sh
cd hw-map-reduce
make
./bin/mr-coordinator
./bin/mr-worker
./bin/mr-client submit -a wc -o /tmp/hw-map-reduce-out -w data/gutenberg/p.txt
./bin/mr-client process -a wc -o /tmp/hw-map-reduce-out
```

### HW 5: MapReduce in Rust

Local execution status: blocked by missing `cargo`.

Static evidence:

- `src/coordinator/mod.rs` still contains job-submission TODOs.
- `src/tests/mod.rs::test_wc` is ignored and contains
  `todo!("Pick an input file")`.

Documentation correctness check:

- The README covers worker registration, job submission, task assignment,
  completion, heartbeat, retry, and end-to-end output validation.
- The missing-test prompts ask for both state-machine unit tests and async
  integration tests.

Completeness verdict: not complete.

Required next tests:

- Finish `test_wc` with a real fixture and expected output.
- Add worker-registration, job-submission, task-assignment, completion, and
  heartbeat/retry tests.
- Add `wc`, `grep`, and `vertex_degree` integration tests with timeouts.

Minimum command set to run in Linux, WSL, or a Rust environment:

```sh
cd hw-map-reduce-rs
cargo test
cargo test test_wc -- --ignored
```

Overall verdict
---------------

The homework documentation is now stronger than a plain official assignment
page because it is tied directly to this repository and its current testing
state. However, the assignments themselves are not fully tested yet.

Readiness by homework:

| Homework | Documentation readiness | Test completeness |
| --- | --- | --- |
| HW 0 Intro | Good | Not complete |
| HW 1 Lists | Good | Not complete |
| HW 2 Shell | Good | Not complete |
| HW 3 HTTP C | Good | Not complete |
| HW 3 HTTP Rust | Good | Partial, not complete |
| HW 4 Memory | Good | Partial, not complete |
| HW 5 MapReduce C | Good | Not complete |
| HW 5 MapReduce Rust | Good | Not complete |

Definition of done for future work
----------------------------------

Each homework should be considered well tested only after all of the following
are true:

1. The homework builds in the expected Linux, WSL, or course VM environment.
2. The documented smoke commands pass.
3. The repository contains deterministic automated tests for the main required
   behavior.
4. Edge cases and failure modes listed in each README are covered.
5. Long-running or environment-sensitive tests have timeouts.
6. The test commands are documented and reproducible from a fresh checkout.
7. Any skipped or ignored test is explained in the README or audit report.
