HW Map Reduce RS
================

Overview
--------

This homework implements the MapReduce system in Rust. It uses Tokio, tonic,
generated protobuf code, and separate binaries for the coordinator, worker, and
client.

Key files
---------

- `Cargo.toml`: Rust package, dependencies, and binary targets.
- `proto/`: coordinator and worker protobuf definitions.
- `src/coordinator/`: coordinator state and RPC handling.
- `src/worker/`: worker behavior and task execution.
- `src/bin/`: `mr-coordinator`, `mr-worker`, `mr-client`, and `mr-autograder`.
- `src/tests/mod.rs`: current local test module.
- `data/`: sample input files.

Build
-----

```sh
cd hw-map-reduce-rs
cargo build
```

Local test plan
---------------

Run the default Rust test command:

```sh
cargo test
```

The included word-count integration-style test is ignored and still contains a
placeholder input path. After replacing the `todo!` with a real input file, run:

```sh
cargo test test_wc -- --ignored
```

Manual service run:

```sh
cargo run --bin mr-coordinator
cargo run --bin mr-worker
cargo run --bin mr-client -- submit -a wc -o /tmp/hw-map-reduce-rs-out -w data/gutenberg/p.txt
cargo run --bin mr-client -- process -a wc -o /tmp/hw-map-reduce-rs-out
```

Run the service commands in separate terminals.

Test completeness review
------------------------

Current status: incomplete. The repository has one ignored test,
`test_wc`, and that test contains `todo!("Pick an input file")`. Default
`cargo test` does not currently validate a working MapReduce cluster.

What is currently covered:

- Compilation through `cargo build` or `cargo test`.
- A draft integration-test shape exists in `src/tests/mod.rs`.

Important gaps:

- No active coordinator state tests.
- No active worker registration, heartbeat, task assignment, or retry tests.
- No active end-to-end job test with deterministic expected output.
- No tests for worker failure, duplicate task completion, multiple jobs, invalid
  app names, empty input, or output cleanup.

Recommended missing tests
-------------------------

- Replace the ignored `test_wc` placeholder with a real temporary input file and
  expected output assertion.
- Add unit tests around coordinator state transitions before relying only on
  end-to-end tests.
- Add Tokio integration tests that start an in-process cluster using
  `utils::start_cluster`.
- Add failure and timeout tests for fault tolerance.
