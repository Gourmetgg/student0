# HW 5: MapReduce (Rust)

Official handout: <https://cs162.org/static/hw/hw-map-reduce-rs/>

## Introduction

This homework is the Rust counterpart to HW 5. You will build a MapReduce
system with `tonic` (gRPC) and the Tokio async runtime: a coordinator
service, worker services, a client CLI, and an autograder driver. The
coordinator must accept job submissions, hand out map tasks before reduces,
collect heartbeats, retry failed tasks, and report job completion or failure.

Grading is split across three deadlines, just like the C version:

| Piece              | Weight | What you submit                            |
| ------------------ | ------ | ------------------------------------------ |
| gRPC Lab (lab-grpc-rs) | 5% | Working KV-store client/server.            |
| Checkpoint         | 5%     | Up through the Tasks section of the spec.  |
| Final              | 90%    | Full system with heartbeats and retries.   |

## Getting Started

Rust development is much faster locally than inside the course Docker.
Install Rust (via `rustup`) and CMake ≥ 3.20 first, then:

```sh
cd ~/code/personal
git pull staff main
cd hw-map-reduce-rs
cargo build
```

Layout:

| Path                       | Role                                         |
| -------------------------- | -------------------------------------------- |
| `proto/`                   | Coordinator and worker protobuf definitions. |
| `src/coordinator/`         | Coordinator service and task queues.         |
| `src/worker/`              | Worker service: registration, heartbeats, exec. |
| `src/client.rs`            | High-level helpers used by client and tests. |
| `src/bin/mr-coordinator.rs` | Coordinator binary.                         |
| `src/bin/mr-worker.rs`     | Worker binary.                               |
| `src/bin/mr-client.rs`     | Client binary.                               |
| `src/bin/mr-autograder.rs` | Autograder driver.                           |
| `src/tests/mod.rs`         | Local cluster integration test (`#[ignore]`). |
| `tests/smoke.rs`           | `cargo test --test smoke` smoke checks.      |
| `data/`                    | Sample inputs.                               |

Run a quick local cluster:

```sh
cargo run --bin mr-coordinator &
cargo run --bin mr-worker &
cargo run --bin mr-client -- submit -a wc -o /tmp/mr-out -w data/gutenberg/p.txt
cargo run --bin mr-client -- process -a wc -o /tmp/mr-out
```

## Tasks

### Worker Registration

Workers must obtain a unique ID from the coordinator on startup and
periodically send heartbeats. Persist enough state in the coordinator to
match heartbeats to outstanding task assignments.

### Job Submission

Accept `submit` requests, validate the app name and reduce count, allocate
a job ID, and return it. Reject submissions for unknown apps with a clear
error.

### Tasks

Hand out map tasks before reduces. Reduce tasks become eligible only once
**every** map for the job has completed. Per task, track `assigned`,
`done`, and `failed` states.

### Fault Tolerance (Final)

A worker that misses heartbeats is treated as dead: its in-flight task is
moved back to the pending queue. Tasks that fail more than `N` times mark
the job as `failed` so the client can stop polling.

## Testing

```sh
make test             # cargo test --test smoke (smoke suite only)
cargo test            # also runs unit tests under src/
cargo test test_wc -- --ignored   # local end-to-end (requires impl)
```

The smoke suite proves that the crate compiles and the three CLI binaries
launch — that is what the repo-level `run_all_tests.sh` runs. The integration
test in `src/tests/mod.rs` boots a 4-worker cluster, submits a `wc` job, and
compares the merged output; it stays `#[ignore]`'d so default `cargo test`
does not run it until you have finished task execution.

## Submission

Push `hw-map-reduce-rs/` to your personal repository. The checkpoint must be
triggered manually from the autograder UI; the final submission runs from
the standard CI flow. See the [Submission
page](https://cs162.org/static/hw/hw-map-reduce-rs/docs/submission/) for the
current deadlines.

## Self-check

Before submitting, take a stab at these. Full answers in
[`STUDY.md`](STUDY.md).

- Why prefer `tokio::sync::Mutex` over `std::sync::Mutex` for state held
  across `.await`?
- Why is `tokio::time::sleep` correct for the heartbeat loop but
  `std::thread::sleep` is dangerous inside an `async fn`?
- Why is `bincode` (or another binary format) the right choice for
  intermediate map output instead of JSON?
- What gives the coordinator its signal that a worker died, even before a
  heartbeat misses?

## References

- Official handout: <https://cs162.org/static/hw/hw-map-reduce-rs/>
- Worker registration: <https://cs162.org/static/hw/hw-map-reduce-rs/docs/worker-registration/>
