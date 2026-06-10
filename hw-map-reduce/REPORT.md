# Lab Report — HW 5: Map Reduce (`hw-map-reduce`)

> Handout: Fall 2025, `cs162.org/static/hw/hw-map-reduce/` (Wayback snapshot 20251110143529).
> Components: RPC lab (5%) → checkpoint (5%, through Tasks; manual autograder trigger) → final.
> Run tests with `bash tests/run.sh` (needs rpcbind for `full/`).

| | |
|---|---|
| Author | |
| Date | |
| Repo commit | |

## 1. Environment

| Item | Value |
|---|---|
| OS / kernel | |
| gcc / rpcgen / libtirpc / glib | |
| rpcbind running? (`sudo service rpcbind start`) | |

## 2. Task Log
*Everything below lives in the coordinator (`coordinator/coordinator.c`) — the
worker, client, apps, and the whole RPC protocol (`rpc/rpc.x`) are given.
The RPC server is single-threaded: no locks needed.*

### 2.1 Job submission (`SUBMIT_JOB`) + data structures
*Unique job IDs from 0, never reused; efficient lookup by ID; FCFS queue; strdup/memcpy RPC buffers; invalid app → error (job_id −1).*

- My data structures (GLib? GHashTable/GQueue/GList) and ownership rules:
- Evidence: `full/20-wc-end-to-end`, `full/22-submit-bad-app`

### 2.2 Job polling (`POLL_JOB`)
*done/failed flags; invalid ID must not crash the coordinator.*

- Semantics chosen for each flag transition:
- Evidence: `full/43-poll-bad-id` (yours)

### 2.3 Task assignment (`GET_TASK`) — checkpoint boundary
*Maps before reduces within a job; FCFS across jobs but work-conserving; never assign a task twice; fill EVERY reply field (NULL strings segfault XDR); wait flag.*

- Queue walk / next-task selection logic:
- Evidence: `full/20`, `full/40-mr-queue-order` + `full/41-mr-no-duplicates` (yours)

### 2.4 Task completion (`FINISH_TASK`)
*All maps done → reduces; all done → job complete; success=false → job fails immediately, stop assigning its tasks.*

- Bookkeeping transitions:
- Evidence: `full/20`, `full/21-grep-end-to-end`, `full/23-vertex-degree-runs`

### 2.5 Fault tolerance (final)
*Track per-task assignment time; reassign incomplete tasks older than TASK_TIMEOUT_SECS; completed tasks never reassigned (outputs on disk).*

- Timestamp storage and the reassignment scan:
- Manual crash drill (handout: sleep after `get_task_1` in worker.c:23, Ctrl-C a worker):
- Evidence: `full/42-map-crash` (yours)

## 3. Official autograder map
`poll-bad-id, wc, grep, vertex-degree, map-parallel(+add-worker),
reduce-parallel(+add-worker), mr-concurrent, coordinator-no-work,
mr-queue-order, queue-map-multiple, mr-no-duplicates, map-crash, reduce-crash,
rand-crash, crash-multi-job, crash-no-duplicates, submit-bad-app, map-error,
reduce-error` — track your status per test here:

| Autograder test | Local analogue | Status | Notes |
|---|---|---|---|
| wc | full/20 | | |
| grep | full/21 | | |
| submit-bad-app | full/22 | | |
| ... | | | |

## 4. Test Results

| Case | Stage | Status | Notes |
|---|---|---|---|
| 10-build / 11-binaries-exist / 12-client-usage | smoke | | |
| full/20..23 | full | | |
| full/40..43 (yours to write) | full | | |

## 5. Debugging Log

| Symptom | Hypothesis | Fix | Test that now catches it |
|---|---|---|---|
| | | | |

## 6. Reflection

- Why the single-threaded RPC server changes (simplifies) the design space:
- The trickiest queueing example from the handout and how my code handles it:
