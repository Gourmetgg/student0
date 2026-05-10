HW Map Reduce
=============

Overview
--------

This homework implements a C MapReduce system with a coordinator, workers, a
client, RPC definitions, and sample applications.

Key files
---------

- `Makefile`: builds the coordinator, worker, and client binaries.
- `rpc/rpc.x`: RPC interface definition.
- `coordinator/coordinator.c` and `coordinator/job.c`: coordinator state and job
  scheduling.
- `worker/worker.c` and `worker/task_handler.c`: worker loop and task execution.
- `client/client.c`: job submission, polling, and output processing.
- `app/wc/`, `app/grep/`, and `app/vertex_degree/`: sample MapReduce apps.
- `data/`: sample input files.

Build
-----

```sh
cd hw-map-reduce
make
```

Local test plan
---------------

Run a three-terminal smoke test.

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
mkdir -p /tmp/hw-map-reduce-out
./bin/mr-client submit -a wc -o /tmp/hw-map-reduce-out -w data/gutenberg/p.txt
./bin/mr-client process -a wc -o /tmp/hw-map-reduce-out
```

Repeat with more worker terminals to exercise parallel scheduling.

Test completeness review
------------------------

Current status: incomplete. No automated test harness was found for the C
MapReduce implementation. The manual cluster run above is only a smoke test.

What is currently covered:

- Compilation of RPC-generated sources and project binaries.
- Manual coordinator, worker, and client interaction.
- Manual word-count job execution.

Important gaps:

- No scripted integration test starts and stops the cluster automatically.
- No golden-output comparison for `wc`, `grep`, or `vertex_degree`.
- No tests for multiple workers, repeated jobs, worker failure, retry behavior,
  empty input, invalid app names, or output directory handling.
- No cleanup logic for generated output and background processes.

Recommended missing tests
-------------------------

- Add an integration script that starts one coordinator, starts several workers,
  submits a job, waits for completion, processes output, and compares against a
  golden file.
- Add tests for all sample apps.
- Add failure tests where a worker exits mid-job and the coordinator reschedules
  the task.
- Add a `make test` target that runs the integration script.
