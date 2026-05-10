HW 5: MapReduce in Rust
=======================

Official reference:

- <https://cs162.org/static/hw/hw-map-reduce-rs/>
- <https://cs162.org/static/hw/hw-map-reduce-rs/docs/worker-registration/>

Assignment goals
----------------

This homework implements the CS 162 MapReduce system in Rust. It uses async
Rust, generated protobuf types, a coordinator service, worker services, and a
client. The official task set covers worker registration, job submission, task
distribution, task completion, heartbeats, retries, and fault tolerance.

Key implementation areas
------------------------

- `proto/`: coordinator and worker protobuf definitions.
- `src/coordinator/`: coordinator state, RPC methods, task queues, and retry
  behavior.
- `src/worker/`: worker registration, heartbeat, task execution, and reporting.
- `src/bin/`: `mr-coordinator`, `mr-worker`, `mr-client`, and
  `mr-autograder`.
- `src/tests/mod.rs`: current draft integration test module.
- `data/`: sample inputs.

Build and run
-------------

```sh
cd hw-map-reduce-rs
cargo build
cargo test
```

Run the ignored draft word-count test after replacing its placeholder input:

```sh
cargo test test_wc -- --ignored
```

Manual service run in separate terminals:

```sh
cargo run --bin mr-coordinator
cargo run --bin mr-worker
cargo run --bin mr-client -- submit -a wc -o /tmp/hw-map-reduce-rs-out -w data/gutenberg/p.txt
cargo run --bin mr-client -- process -a wc -o /tmp/hw-map-reduce-rs-out
```

Current test inventory
----------------------

The repository currently has an ignored `test_wc` in `src/tests/mod.rs`, but
the test still contains a placeholder input path. As a result, default
`cargo test` does not validate a successful MapReduce job.

Completeness assessment
-----------------------

Coverage is incomplete. The Rust implementation needs both coordinator-state
unit tests and async integration tests. The official assignment relies heavily
on distributed state transitions, so the test suite should make those
transitions explicit.

Missing coverage includes:

- Worker IDs are unique and start from the expected value.
- Worker registration stores worker metadata correctly.
- Job IDs are unique.
- New jobs create all map and reduce tasks in the right initial state.
- Task assignment respects map-before-reduce ordering.
- Task completion updates job state.
- Duplicate completion reports do not corrupt state.
- Worker heartbeat timeout triggers retry.
- End-to-end `wc`, `grep`, and `vertex_degree` outputs match golden files.
- Failed workers and cancelled tasks do not hang the cluster.

Detailed missing-test prompts
-----------------------------

1. Finish `src/tests/mod.rs::test_wc`:

   - Replace `todo!("Pick an input file")` with a checked-in fixture or a
     temporary file created inside the test.
   - Submit a `wc` job through the client path.
   - Wait for completion with a timeout.
   - Process output.
   - Sort or normalize output if reducer order is not deterministic.
   - Assert the expected counts.

   Example fixture:

   ```text
   alpha beta alpha
   beta gamma
   ```

   Expected output: `alpha 2`, `beta 2`, `gamma 1`.

2. Add worker-registration unit tests:

   - Call the coordinator registration logic twice.
   - Assert returned worker IDs are `0` and `1` if IDs start from zero.
   - Assert both workers are present in coordinator state.
   - Assert worker address or heartbeat metadata is stored.

3. Add job-submission unit tests:

   - Submit two jobs and assert job IDs are sequential.
   - Assert input file lists, output directory, app name, app args, and reducer
     count are copied into coordinator state.
   - Assert every map task starts as not started.
   - Assert reduce tasks are not assigned before map tasks finish.

4. Add task-assignment tests:

   - Register two workers.
   - Submit a job with multiple input files.
   - Request tasks from both workers.
   - Assert they do not receive the same in-progress task unless retry logic has
     intentionally made the task available again.

5. Add task-completion tests:

   - Mark a map task complete and assert its state changes.
   - Complete all map tasks and assert reduce tasks become assignable.
   - Complete all reduce tasks and assert the job reaches done state.
   - Send a duplicate completion report and assert it is ignored safely.

6. Add heartbeat and retry tests:

   - Register a worker and assign it a task.
   - Advance the coordinator's notion of time or wait past the heartbeat
     timeout.
   - Assert the task returns to the available queue.
   - Assert another worker can receive and finish that task.

7. Add integration tests using the existing cluster utilities:

   - Start an in-process coordinator and multiple workers, for example with
     `utils::start_cluster` if that helper is available.
   - Use `#[tokio::test]`.
   - Use `tokio::time::timeout` around the whole test.
   - Submit `wc`, `grep`, and `vertex_degree` jobs using tiny deterministic
     fixtures.

8. Add invalid-input integration tests:

   - Unknown app name.
   - Missing input path.
   - Output directory that cannot be created.
   - Zero reducers if the API rejects that case.

   Assert the client receives a clean error and the coordinator remains alive.

9. Add output-cleanup checks:

   - Use `tempfile::TempDir` for each test.
   - Assert intermediate files are written where expected.
   - Assert processed output is deterministic.
   - Let `TempDir` remove generated files after the test.

Suggested commands
------------------

```sh
cargo test
cargo test test_wc -- --ignored
cargo test -- --nocapture
```

Keep deterministic state-machine tests active in the default `cargo test`
suite. Keep slow fault-tolerance tests active if they are reliable; otherwise
mark them ignored with a clear comment and run them in CI or before submission.
