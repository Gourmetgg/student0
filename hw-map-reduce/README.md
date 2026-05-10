HW 5: MapReduce in C
====================

Official reference:

- <https://cs162.org/static/hw/hw-map-reduce/>
- <https://cs162.org/static/hw/hw-map-reduce/docs/job-submission/>

Assignment goals
----------------

This homework implements a distributed MapReduce system in C. The official CS
162 task set covers job submission, worker registration, task distribution,
worker heartbeats, task completion, fault tolerance, and output processing.

The coordinator should maintain durable job and task state, workers should
request and execute tasks, and the client should submit jobs and process final
outputs from sample applications.

Key implementation areas
------------------------

- `rpc/rpc.x`: RPC interface shared by coordinator, worker, and client.
- `coordinator/coordinator.c`: RPC service entry points and scheduler logic.
- `coordinator/job.c`: job metadata, task state, queues, and transitions.
- `worker/worker.c`: worker registration, polling, heartbeat, and task loop.
- `worker/task_handler.c`: map and reduce task execution.
- `client/client.c`: job submission, polling, and output processing.
- `app/wc/`, `app/grep/`, `app/vertex_degree/`: sample MapReduce apps.
- `data/`: sample input data.

Build and run
-------------

```sh
cd hw-map-reduce
make
```

Manual three-terminal smoke test:

Terminal 1:

```sh
./bin/mr-coordinator
```

Terminal 2:

```sh
./bin/mr-worker
```

Terminal 3:

```sh
rm -rf /tmp/hw-map-reduce-out
mkdir -p /tmp/hw-map-reduce-out
./bin/mr-client submit -a wc -o /tmp/hw-map-reduce-out -w data/gutenberg/p.txt
./bin/mr-client process -a wc -o /tmp/hw-map-reduce-out
```

Current test inventory
----------------------

No checked-in automated harness was found for the C MapReduce implementation.
The current coverage is manual cluster execution only.

Completeness assessment
-----------------------

Coverage is incomplete. MapReduce correctness depends on multi-process
coordination, so the important tests must start real coordinator and worker
processes, submit real jobs, and compare output against golden files.

Missing coverage includes:

- Job IDs are unique and start from the expected value.
- Job submission deeply copies input paths, output paths, app names, and app
  arguments.
- Output directories are created when missing.
- Map and reduce tasks are initialized as not started.
- Workers receive unique IDs.
- Multiple workers share tasks without duplicate ownership.
- Completed tasks advance job state correctly.
- Worker failure causes task retry.
- Sample apps produce deterministic output.
- Invalid job submissions fail cleanly.

Detailed missing-test prompts
-----------------------------

1. Add `tests/run_cluster_test.sh`:

   - Build with `make`.
   - Create a temporary output directory.
   - Start `./bin/mr-coordinator` in the background.
   - Start one or more `./bin/mr-worker` processes.
   - Submit a job.
   - Poll until completion.
   - Run `mr-client process`.
   - Compare processed output against a golden file.
   - Clean up all background processes in a `trap`.

   Process cleanup is essential because failed MapReduce tests otherwise leave
   coordinators or workers running on the host.

2. Add word-count golden coverage:

   Create `tests/fixtures/wc_input.txt`:

   ```text
   alpha beta alpha
   beta gamma
   ```

   Expected processed output should include:

   ```text
   alpha 2
   beta 2
   gamma 1
   ```

   Sort output before comparison if reducer output order is not guaranteed.

3. Add multi-file job coverage:

   Submit one job with two or more `-w` input files. Put overlapping words in
   multiple files so the reduce step must combine mapper outputs correctly.

4. Add multiple-worker coverage:

   Start three workers and submit a job with enough map tasks to distribute.
   Assert the job completes and output matches the single-worker golden result.
   This catches coordinator state bugs that only appear with concurrent worker
   requests.

5. Add worker-failure coverage:

   - Start the coordinator and two workers.
   - Submit a job with multiple tasks.
   - Kill one worker while the job is running.
   - Assert the coordinator marks its in-progress task available again.
   - Assert the final output still matches the golden result.

6. Add invalid submission tests:

   - Unknown app name.
   - Missing input file.
   - Output path that cannot be created.
   - Invalid reducer count if the client exposes that option.

   Each should return a failure status without crashing the coordinator.

7. Add coordinator-state unit tests if internal functions are linkable:

   - Submitting the first job returns ID `0`.
   - Submitting a second job returns ID `1`.
   - Newly submitted jobs have all map and reduce tasks in `NOT_STARTED`.
   - Deep-copied strings remain valid after the request object is freed.
   - Output directory creation is attempted exactly once.

8. Add sample-app coverage:

   - `wc`: compare against a small word-count golden file.
   - `grep`: use a fixture where only known lines match.
   - `vertex_degree`: use a tiny graph with known degrees.

9. Add timeout protection:

   Every integration test should fail after a fixed timeout, for example 30
   seconds, so scheduler deadlocks become visible instead of hanging forever.

Suggested `make test` target
----------------------------

Add `make test` to run the fast deterministic integration cases. Keep
worker-failure and large stress tests behind a separate `make stress` target if
they are slower or more environment-sensitive.
