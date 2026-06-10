# HW 5 (Rust) — Writing the Test Suite

Companion to `tests/smoke.rs` and `src/tests/mod.rs`. Read
[`docs/testing-tutorial.md`](../docs/testing-tutorial.md) first.

Unlike the C version, the Rust crate exposes a *library* (`map_reduce`)
that integration tests can import. Use that — running an in-process
cluster is much faster than spawning binaries.

## What you're testing

| Feature                                          | Test type           |
| ------------------------------------------------ | ------------------- |
| Three CLI binaries respond to `--help`           | smoke               |
| `submit_job` returns a unique id                 | unit                |
| `submit_job` rejects unknown app names           | unit, `Err` arm     |
| Poll on unknown job id returns clean error       | unit                |
| Map tasks dispatched before reduce tasks         | sequencing          |
| Reduces only after every map done                | sequencing          |
| Duplicate completion message is ignored          | idempotency         |
| Worker that disappears triggers task reassign    | fault injection     |
| `test_wc` end-to-end passes                      | integration         |

## Recipe

1. **Smoke** (already in `tests/smoke.rs`). Binaries build.
2. **Unit: `submit_job`.** Use `start_cluster(0)` to get just a
   coordinator (no workers). Submit `wc` — expect `Ok(job_id)`. Submit
   `not-an-app` — expect `Err(Status::invalid_argument(...))`. Submit
   with `n_reduce = 0` — pin a behavior.
3. **Unit: poll.** Coordinator-only. Call `poll_job(99999)` — assert
   the error variant you chose.
4. **Sequencing test.** 1 worker. Submit a job with 2 maps + 2
   reduces. Instrument the worker to log each task ID it picks up.
   Assert all map IDs appear before any reduce ID.
5. **Idempotency.** Run `test_wc` with a worker that calls
   `report_task_done` twice for the same task. Job should still
   succeed; output should not duplicate.
6. **Fault injection.** `start_cluster(2)`; abort one worker after the
   first task assignment; let the other worker finish. Assert job
   completes within a deadline.
7. **End-to-end `test_wc`.** Already drafted in `src/tests/mod.rs`,
   currently `#[ignore]`d. Once your implementation is ready, drop
   the ignore (or pass `--ignored`).

## Why in-process testing wins

The C version has to spawn coordinator and worker as separate
processes — `cargo test` for the Rust crate can run them as async
tasks in the same runtime. That means:

- No `rpcbind`, no fixed ports (use `127.0.0.1:0`).
- The test owns the runtime, so `tokio::time::sleep` is a controllable
  fake clock — see `tokio::test(start_paused = true)`.
- `start_cluster(n)` spawns `n` worker tasks plus a coordinator task
  and returns once they're ready.

## start_cluster shape

```rust
pub async fn start_cluster(n_workers: usize) -> Cluster {
    let coord = spawn_coordinator().await;
    let workers = (0..n_workers)
        .map(|_| spawn_worker(coord.addr()))
        .collect::<Vec<_>>();
    Cluster { coord, workers }
}
```

`Cluster` has a `Drop` impl that aborts every task. Use it as the
ambient cleanup — tests don't need an explicit teardown.

## Try it yourself

1. Write the sequencing test described above. The simplest
   instrumentation is `tracing::info!("task {id} {kind}")` and a
   `tracing-subscriber` `MakeWriter` that captures into a `Vec`.
   What other approaches did you consider, and why pick this one?
2. The `test_wc` fixture path is currently `data/gutenberg/p.txt`.
   That's a large file. Build a 3-line fixture (`tests/fixtures/tiny.txt`)
   and a `wc.expected.txt` you computed by hand. Now the failure mode
   "test takes a while" is decoupled from "test runs at all."
3. `tokio::test(start_paused = true)` pauses the runtime's clock. Try
   it on the heartbeat-timeout test: advance the clock past the
   deadline manually and assert the coordinator reaps the worker.
   Why is this dramatically more reliable than `tokio::time::sleep`?
4. The `#[ignore]` attribute hides a test from default runs. List the
   pros and cons of `#[ignore]` vs gating on a Cargo feature flag
   (`#[cfg(feature = "integration")]`).
5. Use `cargo test -- --nocapture` to see worker logs interleaved
   with test output. Find an interleaving that obscures a real bug —
   what's the fix? (Hint: per-test log subscriber, not global.)

## Common pitfalls

- **`async fn` without an executor.** Bare `#[test]` on an async
  function is a no-op. Always use `#[tokio::test]` or wrap in
  `Runtime::new().block_on(...)`.
- **`std::sync::Mutex` across `.await`.** Deadlocks the executor;
  `cargo test` hangs forever. Use `tokio::sync::Mutex` or drop the
  guard before the await.
- **Ports leak between tests.** Always bind to `0`; never hardcode.
- **`Drop` doesn't run on panic in `tokio::test`?** It does, but the
  abort can be racy. Use `tokio::task::JoinSet::abort_all()` rather
  than relying on Drop for the cleanup path.
- **`#[ignore]`d tests still must compile.** A `todo!()` inside an
  ignored test breaks `cargo test`. Replace with a real value or
  `unimplemented!()` *and* `#[cfg(any())]` to skip compilation
  entirely.
