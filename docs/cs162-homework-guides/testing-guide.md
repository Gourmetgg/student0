CS 162 Homework Testing Guide
=============================

Purpose
-------

This guide explains how to finish and test each homework in this repository
without relying on blind manual inspection. The goal is not merely to run a few
smoke commands. A homework should be considered ready only when its tests cover
the required behavior, edge cases, failure paths, and concurrency risks that are
natural for that assignment.

The guidance is based on the public CS 162 homework pages and on a local WSL
validation pass using a disposable scratch copy of this repository. The scratch
copy was used to complete representative implementations and verify which tests
were strong enough to catch real mistakes. The tracked source code in this
repository is intentionally left unchanged.

Completeness Standard
---------------------

A test suite is complete enough for these homework assignments when all of the
following are true:

1. The project builds from a clean checkout in the documented environment.
2. Tests are automated and can be run by one command per homework.
3. Each required feature has at least one positive test and one meaningful edge
   or failure test.
4. Output tests compare exact behavior, not just process exit status.
5. Nondeterministic output is normalized before comparison, or the test asserts
   a set of required facts instead of a fragile ordering.
6. Concurrent code is tested repeatedly and under enough load to expose lost
   updates, races, deadlocks, and missing joins.
7. Long-running tests use timeouts and always clean up child processes.
8. Every test fixture has a clear reason to exist.
9. Ignored, skipped, or environment-sensitive tests are documented.
10. A fresh clone can reproduce the same result.

No finite test suite can prove the absence of every bug. In this guide,
"complete" means complete against the assignment contract: every official task,
important edge case, and known local failure mode has a targeted test.

Recommended Environment
-----------------------

Use WSL Ubuntu or the CS 162 course VM. After installing dependencies, verify
the toolchain:

```sh
command -v make
command -v gcc
command -v cargo
command -v rustc
command -v rpcgen
ls /usr/include/tirpc/rpc/rpc.h
pkg-config --cflags glib-2.0
qemu-system-i386 --version
```

Useful packages include:

```sh
sudo apt update
sudo apt install -y \
  build-essential make gcc g++ gcc-multilib gdb perl pkg-config \
  qemu-system-x86 \
  libtirpc-dev libnsl-dev libglib2.0-dev rpcbind rpcsvc-proto \
  protobuf-compiler curl
```

For Rust, prefer `rustup` so each `rust-toolchain.toml` can select the intended
toolchain:

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
cargo --version
rustc --version
```

How To Write Good Tests
-----------------------

Use small fixtures first. A fixture should be short enough that a human can
compute the expected output. Add large stress fixtures only after the small
fixtures catch basic mistakes.

Prefer golden files for deterministic output. For example, a word-count test
should redirect output to a temporary file and compare it with `diff -u`.

Normalize when order is not part of the contract. If an assignment does not
require output ordering, sort both the expected and actual outputs before
comparing. If ordering is required, assert the exact order.

Always test errors. Missing files, invalid flags, malformed HTTP requests,
invalid job IDs, and failed workers should be part of the suite.

Use timeouts. Shell, HTTP, MapReduce, and Pintos tests can hang when something
is wrong. Every integration test should use `timeout`, and every server test
should kill child processes in a cleanup trap.

Separate smoke, functional, and stress tests:

- Smoke tests answer "does it start and produce any plausible output?"
- Functional tests answer "does it implement the required behavior exactly?"
- Stress tests answer "does it survive repeated, concurrent, or large input?"

Keep a coverage matrix. For each homework, list the features in rows and the
tests in columns. A row with no test is a missing test, even if the code looks
correct.

HW 0: Intro
-----------

Required behavior:

- Build `limits`, `map`, and `words`.
- Count total words from files and stdin.
- Count word frequencies case-insensitively.
- Treat alphabetic runs as words and punctuation as separators.
- Combine counts across multiple files.
- Fail cleanly for missing files and invalid flags.

Minimum test set:

```sh
cd hw-intro
make
./limits
./map
cd words
make
```

Create fixtures:

```sh
mkdir -p tests
printf 'Hello, hello HELLO world.\nCS162 systems.\n' > tests/basic.txt
printf 'one two\n' > tests/a.txt
printf 'two THREE\n' > tests/b.txt
```

Suggested assertions:

```sh
./words -c tests/basic.txt | grep 'The total number of words is: 6'
./words -f tests/basic.txt | grep $'3\thello'
printf 'one two one\n' | ./words -f | grep $'2\tone'
./words -c tests/a.txt tests/b.txt | grep 'The total number of words is: 4'
! ./words -c tests/missing.txt
```

Completeness gate:

- Empty input is tested.
- Punctuation and mixed case are tested.
- Stdin and multi-file input are tested.
- Missing file returns nonzero.
- Frequency output is compared by content, with order handled explicitly.

HW 1: Lists
-----------

Required behavior:

- Implement Pintos-list-backed word counts.
- Implement pthread-safe word counts.
- `lwords` and `pwords` should match the reference `words` output.
- `pwords` should spawn one thread per input file and join all workers.

Minimum test set:

```sh
cd hw-list
make
```

Create fixtures with repeated words across files:

```sh
mkdir -p tests
printf 'Alpha beta beta gamma gamma gamma\n' > tests/a.txt
printf 'beta delta delta\n' > tests/b.txt
```

Suggested assertions:

```sh
./words tests/a.txt > /tmp/ref-a.out
./lwords tests/a.txt > /tmp/lwords-a.out
./pwords tests/a.txt > /tmp/pwords-a.out
diff -u /tmp/ref-a.out /tmp/lwords-a.out
diff -u /tmp/ref-a.out /tmp/pwords-a.out

./words tests/a.txt tests/b.txt > /tmp/ref-ab.out
for i in $(seq 1 50); do
  ./pwords tests/a.txt tests/b.txt > /tmp/pwords-ab.out
  diff -u /tmp/ref-ab.out /tmp/pwords-ab.out
done
```

Completeness gate:

- `lwords` matches `words`.
- `pwords` matches `words` for one file and multiple files.
- Repeated parallel runs do not lose increments.
- Missing input file returns nonzero.
- Large input and memory-check runs are included.

HW 2: Shell
-----------

Required behavior:

- Built-ins: `cd`, `pwd`, `exit`, and help.
- External program execution through `fork` and `exec`.
- Path resolution through `execvp` or equivalent.
- Input and output redirection.
- Pipelines.
- EOF, Ctrl-C, and Ctrl-Z behavior.

Minimum deterministic tests:

```sh
cd hw-shell
make
printf 'pwd\n' | ./shell
printf 'cd /\npwd\n' | ./shell
printf '/bin/echo hello\n' | ./shell
printf '/bin/echo hello | /usr/bin/wc -w\n' | ./shell
printf '/bin/echo redirected > /tmp/shell-out\n/bin/cat < /tmp/shell-out\n' | ./shell
```

Signal tests should use a pseudo-terminal harness. Do not test Ctrl-C and
Ctrl-Z with a plain pipe; job-control behavior depends on terminal process
groups.

Completeness gate:

- Built-ins work and affect the shell process where appropriate.
- External commands return expected stdout and exit behavior.
- Redirection creates and reads files correctly.
- Pipelines pass bytes between processes.
- Invalid commands and invalid redirection paths fail cleanly.
- Signal behavior is tested under a PTY with timeouts.

HW 3: HTTP Server in C
----------------------

Required behavior:

- Bind and listen on the requested port.
- Parse HTTP requests.
- Serve files with correct status, body, MIME type, and content length.
- Serve `index.html` for directories when present.
- Generate directory listings when no index exists.
- Reject path traversal.
- Return 404 or 405 for invalid paths or methods.
- Support basic, fork, thread, and pool server variants.
- Proxy mode should relay bytes to and from an upstream server.

Minimum integration test pattern:

```sh
cd hw-http
make
./httpserver --files www --port 18080 &
server=$!
sleep 1
curl --noproxy '*' -D /tmp/http.h http://127.0.0.1:18080/ -o /tmp/http.b
grep 'HTTP/1.0 200 OK' /tmp/http.h
grep 'CS 162' /tmp/http.b
kill "$server"
```

Repeat the same test shape for `forkserver`, `threadserver`, and `poolserver`.
For `poolserver`, pass `--num-threads`.

Completeness gate:

- Every server variant is tested.
- `200`, `403`, `404`, and malformed request paths are tested.
- Directory, file, and traversal cases are tested.
- Concurrent clients are tested with many simultaneous `curl` requests.
- Every server process is cleaned up by a trap.

HW 3: HTTP Server in Rust
-------------------------

Required behavior:

- Request parsing.
- Response formatting.
- MIME type lookup.
- Async listener and per-socket handling.
- Static file and directory serving.
- Stats tracking.

Minimum commands:

```sh
cd hw-http-rs
cargo test
cargo run -- --files www --port 18080
```

Unit tests should cover:

- `get_mime_type`.
- `start_response`, `send_header`, and `end_headers`.
- `parse_request` for complete, partial, malformed, and unsupported requests.
- `Stats::incr`, sorted `items`, and async shared stats updates.

Integration tests should start the real server on an ephemeral port and use a
TCP client to assert response status, headers, body, and stats.

Completeness gate:

- Existing helper tests pass.
- Real TCP integration tests exist.
- Directory, missing-file, traversal, and concurrent request cases are tested.
- Stats are checked after real requests, not only by unit tests.

HW 4: Memory
------------

Required behavior:

- Standalone `mm_alloc` implements `mm_malloc`, `mm_realloc`, and `mm_free`.
- Pintos user `sbrk` grows and shrinks the process heap.
- User `malloc`, `free`, and `realloc` work through `sbrk`.

Standalone allocator tests:

```sh
cd hw-memory/mm_alloc
make
./mm_test
```

Add tests for:

- `mm_malloc(0)`.
- Alignment of returned pointers.
- Writing every allocated byte.
- `mm_free(NULL)`.
- Reuse after free.
- Realloc growth preserves old bytes.
- Realloc shrink preserves the prefix.
- Many small allocations and frees.

Pintos tests:

```sh
cd hw-memory/pintos/src/memory
make
env PATH=../../utils:../utils:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make check
```

Completeness gate:

- Standalone allocator tests pass.
- Active Pintos memory suite passes.
- The suite reports all 26 active tests passed.
- Out-of-memory and deallocation behavior are included.
- If stack-growth tests are enabled for a different assignment version, they
  must be added to the gate explicitly.

HW 5: MapReduce in C
--------------------

Required behavior:

- Coordinator accepts job submissions.
- Workers receive map and reduce tasks.
- Map output is partitioned by reduce task.
- Reduce output is written deterministically.
- Clients can poll job status and post-process final output.
- Failed workers or failed tasks are retried or marked failed according to the
  assignment contract.

Minimum commands:

```sh
cd hw-map-reduce
make
./bin/mr-coordinator
./bin/mr-worker
./bin/mr-client submit -a wc -n 2 -o /tmp/mr-out -w data/gutenberg/p.txt
./bin/mr-client process -a wc -n 2 -o /tmp/mr-out
```

Integration test pattern:

- Start coordinator in the background.
- Start several workers in the background.
- Submit a small `wc` job with known input.
- Wait for completion with a timeout.
- Run `process` and compare output with a golden file.
- Kill all children in a cleanup trap.

Completeness gate:

- Build succeeds.
- `wc`, `grep`, and `vertex-degree` jobs pass.
- Empty input and invalid app names are tested.
- Invalid job IDs are tested.
- Worker failure during a map task is tested.
- Worker failure during a reduce task is tested.
- Output directories are isolated per test.

HW 5: MapReduce in Rust
-----------------------

Required behavior:

- Worker registration and heartbeats.
- Job submission and polling.
- Map and reduce task assignment.
- Task completion and failure reporting.
- Retry behavior for retryable failures.
- End-to-end `wc`, `grep`, and `vertex-degree` outputs.

Minimum commands:

```sh
cd hw-map-reduce-rs
cargo test
cargo test test_wc -- --ignored
```

Unit tests should cover:

- Unique worker IDs.
- Valid and invalid job submission.
- Polling unknown job IDs.
- Map-task assignment before reduce-task assignment.
- Reduce assignment only after all maps finish.
- Duplicate completion messages.
- Failed task retry policy.

Integration tests should use `start_cluster`, submit jobs through the real
client, wait with a timeout, and compare final output to golden files.

Completeness gate:

- Default `cargo test` compiles and passes.
- Ignored end-to-end tests are either enabled in CI or documented as manual.
- The `test_wc` fixture path is real and checked in.
- The suite includes worker failure and retry tests.
- Output comparison is deterministic.

Final Readiness Checklist
-------------------------

Before calling a homework complete, record:

- The exact command used to run tests.
- The environment where it was run.
- The number of tests passed.
- Any tests skipped and why.
- Any behavior not covered by automated tests.
- Any manual checks still required.

If a homework needs implementation changes, make those changes separately from
documentation updates. This repository currently keeps the homework source code
unchanged and tracks only the lab documentation.
