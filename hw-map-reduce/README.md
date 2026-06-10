# HW 5: MapReduce (C)

Official handout: <https://cs162.org/static/hw/hw-map-reduce/>

## Introduction

MapReduce is a programming model for scalable, parallel data processing. In
HW 5 you build a fault-tolerant MapReduce system in C: a **coordinator** that
distributes work, a pool of **workers** that execute map and reduce tasks,
and a **client** that submits jobs and post-processes the final output. The
coordinator must handle worker registration, hand out tasks in dependency
order (maps before reduces), track per-task state, and re-issue work when a
worker disappears.

The assignment is graded in three pieces with separate deadlines:

| Piece              | Weight | What you submit                            |
| ------------------ | ------ | ------------------------------------------ |
| RPC Lab (lab-rpc)  | 5%     | Working ECHO / PUT / GET via `rpcgen`.     |
| Checkpoint         | 5%     | Up through the Tasks section of the spec.  |
| Final              | 90%    | Full system including fault tolerance.     |

Slip days apply; there are no other extensions.

## Getting Started

```sh
cd ~/code/personal
git pull staff main
cd hw-map-reduce
make
```

Layout:

| Path                  | Role                                           |
| --------------------- | ---------------------------------------------- |
| `rpc/rpc.x`           | Shared RPC interface (`rpcgen` source).        |
| `coordinator/`        | `coordinator.c` (RPC entry points), `job.c`.   |
| `worker/`             | `worker.c` (loop), `task_handler.c` (execute). |
| `client/client.c`     | `submit` and `process` commands.               |
| `app/{wc,grep,vertex_degree}/` | Sample MapReduce apps.              |
| `data/`               | Sample inputs.                                 |

Run the three binaries from three terminals (or `tmux` panes):

```sh
./bin/mr-coordinator
./bin/mr-worker
./bin/mr-client submit -a wc -n 2 -o /tmp/mr-out -w data/gutenberg/p.txt
./bin/mr-client process -a wc -n 2 -o /tmp/mr-out
```

## Tasks

### Job Submission

In `coordinator.c`, accept `submit` requests, allocate a `Job` (see
`coordinator/job.h`), persist task metadata, and respond with a job ID.

### Worker Registration and Tasks

On the worker side, register with the coordinator on startup, poll for work,
execute the assigned map or reduce, and report completion (or failure). On
the coordinator side, hand out map tasks before any reduce tasks, and only
schedule a reduce when its input partition is fully populated.

### Output Processing

The client `process` command merges the per-reduce output files into the
final order the spec dictates. `app/<name>/<name>.c` defines the map / reduce
callbacks and the post-processing format.

### Fault Tolerance (Final)

Track per-worker heartbeats. If a worker misses several heartbeats, mark its
in-flight task `failed`, requeue it, and continue. After a configurable
retry count, mark the job as failed and report that to the client.

## Testing

```sh
make test
```

The default suite confirms that `rpcgen` produced stubs, the three binaries
link, and the client does not hang on bad input. End-to-end coverage that
starts a coordinator + worker and submits a real `wc` job is gated behind
`RUN_FULL=1` because it requires the RPC plumbing to actually work plus a
running `rpcbind` daemon:

```sh
sudo service rpcbind start
RUN_FULL=1 make test
```

For deeper coverage, extend `tests/run.sh` to (1) submit the three sample
apps (`wc`, `grep`, `vertex_degree`), (2) compare output to checked-in
golden files, and (3) kill a worker mid-task to exercise the retry path.

## Submission

Push `hw-map-reduce/` to your personal repository on the relevant deadline.
The checkpoint must be triggered manually from the autograder UI; the final
submission auto-runs from the standard CI flow. See the [Submission
page](https://cs162.org/static/hw/hw-map-reduce/docs/submission/) for the
current cut-offs.

## Self-check

Before submitting, take a stab at these. Full answers in
[`STUDY.md`](STUDY.md).

- Why must every map task complete before any reduce task is dispatched?
- What goes wrong if two workers use different hash functions to partition
  map output?
- Why is "re-issue in-flight tasks" correct on worker failure but
  "re-execute completed tasks" *not*?
- Why should the worker's heartbeat thread use a separate RPC connection
  from its task thread?

## References

- Official handout: <https://cs162.org/static/hw/hw-map-reduce/>
- Job submission: <https://cs162.org/static/hw/hw-map-reduce/docs/job-submission/>
