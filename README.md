CS 162 Student Repository
=========================

This repository contains code for CS 162 individual assignments.

How to test each homework
-------------------------

The commands below assume a Linux, WSL, or course VM environment with the
assignment dependencies installed. C assignments generally use `make`; Rust
assignments use `cargo`. If a command fails because a `TODO` is still
unimplemented, that failure is useful feedback about the part to finish next.

### `hw-intro`

Build and run the address-space and limit exercises:

```sh
cd hw-intro
make
./limits
./map
```

Build and test the word-count exercise:

```sh
cd hw-intro/words
make
./words -h
./words -c words.txt
./words -f words.txt
./words -c gutenberg/alice.txt
```

### `hw-list`

Build all programs:

```sh
cd hw-list
make
```

Run the pthread demo and compare the word-count implementations on the same
inputs:

```sh
./pthread 4
./words gutenberg/alice.txt
./lwords gutenberg/alice.txt
./pwords gutenberg/alice.txt gutenberg/sawyer.txt
```

The `words`, `lwords`, and `pwords` outputs should agree for the same input
files. Use `make clean` before rebuilding from scratch.

### `hw-shell`

Build the shell and run the included smoke test:

```sh
cd hw-shell
make
bash test.sh
```

You can also test individual commands manually:

```sh
echo "pwd" | ./shell
echo "/bin/ls" | ./shell
```

### `hw-memory`

For the allocator exercise:

```sh
cd hw-memory/mm_alloc
make
./mm_test
```

For the Pintos memory tests, use the course Pintos environment with QEMU and
the 32-bit toolchain available:

```sh
cd hw-memory/pintos/src/memory
make check
```

After `make check` creates the `build` directory, you can run one test result
target at a time from `hw-memory/pintos/src/memory/build`, for example:

```sh
make tests/memory/malloc-simple.result
```

### `hw-map-reduce`

Build the C MapReduce binaries:

```sh
cd hw-map-reduce
make
```

Run a local smoke test with three terminals. Start the coordinator in terminal
1:

```sh
./bin/mr-coordinator
```

Start a worker in terminal 2:

```sh
./bin/mr-worker
```

Submit and process a word-count job in terminal 3:

```sh
mkdir -p /tmp/hw-map-reduce-out
./bin/mr-client submit -a wc -o /tmp/hw-map-reduce-out -w data/gutenberg/p.txt
./bin/mr-client process -a wc -o /tmp/hw-map-reduce-out
```

Add more `mr-worker` processes in additional terminals to test parallel work.

### `hw-map-reduce-rs`

Run Rust compile checks and unit tests:

```sh
cd hw-map-reduce-rs
cargo test
```

The included `test_wc` integration-style test is ignored and contains a
placeholder input file. After replacing the `todo!` with a real input path, run
it with:

```sh
cargo test test_wc -- --ignored
```

You can also start the Rust services manually:

```sh
cargo run --bin mr-coordinator
cargo run --bin mr-worker
cargo run --bin mr-client -- submit -a wc -o /tmp/hw-map-reduce-rs-out -w data/gutenberg/p.txt
cargo run --bin mr-client -- process -a wc -o /tmp/hw-map-reduce-rs-out
```

Run those service commands in separate terminals.

### `hw-http`

Build the C HTTP servers:

```sh
cd hw-http
make
```

Start one server, then test it from another terminal with `curl`:

```sh
./httpserver --files www --port 8000
curl -i http://127.0.0.1:8000/
curl -i http://127.0.0.1:8000/my_documents/wholesome_facts.txt
```

Repeat the same curl checks with the other server variants:

```sh
./forkserver --files www --port 8000
./threadserver --files www --port 8000
./poolserver --files www --port 8000 --num-threads 4
```

Use a different port if `8000` is already in use.

### `hw-http-rs`

Run Rust tests:

```sh
cd hw-http-rs
cargo test
```

Run the server and test it with `curl` from another terminal:

```sh
cargo run -- --files www --port 8000
curl -i http://127.0.0.1:8000/
curl -i http://127.0.0.1:8000/my_documents/wholesome_facts.txt
```

Use `cargo clean` if you need a fresh Rust rebuild.
