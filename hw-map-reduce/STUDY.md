# HW 5: Understanding Check (C)

Self-check questions for HW 5 (C). Written by the maintainers of this
repo, not the CS 162 staff.

## 1. The MapReduce paper says the coordinator is a "single point of failure" but treats that as acceptable. Why does the design tolerate that for the *coordinator* but not for *workers*?

<details><summary>Answer</summary>

Workers vastly outnumber coordinators in a real cluster — losing one
worker has a low probability and a low impact, so retrying its task on
another worker is cheap. Losing the coordinator is rare and catastrophic
(the whole job state vanishes), so the design optimizes for the common
case: many cheap failures, not one rare one. Production systems
checkpoint coordinator state to durable storage and restart on a healthy
host, which is the fault-tolerance gap the paper accepts.

</details>

## 2. Why must every map task complete before any reduce task starts?

<details><summary>Answer</summary>

Each reduce task `r` reads its inputs from partition `r` produced by
*every* map task. If any map for the job has not finished, reduce `r`
will see a partial view of partition `r` and produce wrong output. The
coordinator enforces the barrier by tracking remaining maps; reduce
becomes assignable only when the counter hits zero. Within a *task*
class, ordering does not matter — maps are independent of each other,
and reduces are independent of each other.

</details>

## 3. The worker hashes each emitted key with `hash(key) % nReduce` to choose a partition. What goes wrong if two workers use *different* hash functions?

<details><summary>Answer</summary>

A given key ends up in different partition files depending on which
worker produced the map output. Reduce task `r` then sees the same key
split across multiple partitions and others miss the key entirely. The
final count for that key is wrong. The hash function is part of the
*protocol*, not a worker implementation detail; ship it from a shared
header so every worker computes the same partition for the same key.

</details>

## 4. A worker accepts a task, runs for a while, and then crashes silently. The coordinator detects the loss via missed heartbeats. Why is "tasks the worker had checked out get reassigned" the right policy, and what bug appears if you also re-execute *completed* tasks?

<details><summary>Answer</summary>

Reassigning in-flight tasks preserves progress: the work is incomplete,
so someone else has to redo it. Re-executing completed tasks would
produce duplicate output. Reduce tasks are particularly sensitive — two
workers running the same reduce write the *same* output file
concurrently and either corrupt it or hand you twice the values. The
coordinator must distinguish `assigned` from `done` and only reissue
`assigned` work. (Real systems also require map output to be atomically
renamed to its final name so duplicate maps are deduplicated.)

</details>

## 5. Why are `rpcgen`-style RPCs called "synchronous" and what implication does that have for the worker's heartbeat thread?

<details><summary>Answer</summary>

SunRPC is request/response over a single connection: the caller blocks
until the server replies. If the worker uses one connection for both
task RPCs *and* heartbeats, a stuck task RPC blocks heartbeats — the
coordinator marks the worker dead even though it is fine. The fix is a
separate connection for heartbeats (or a worker thread dedicated to
heartbeats that holds its own client handle).

</details>

## 6. The `process` step on the client merges per-reduce output files. Why is this client-side and not coordinator-side?

<details><summary>Answer</summary>

Keeping merge logic on the client keeps the coordinator's
responsibilities small (scheduling and state, not data). The client
already has to be on a machine that can read the output directory, and
the merge is embarrassingly parallel — different clients with different
post-processing needs can do it independently. In a real cluster the
output files are also typically left in place so downstream MapReduce
jobs can use them as input; the "merged final answer" is just one
post-processing choice.

</details>

## 7. The RPC interface is shared by coordinator, worker, and client. What's the rule for *who* may add a field to a request struct, and why does breaking that rule cause silent bugs?

<details><summary>Answer</summary>

The interface is owned by the coordinator; both worker and client are
*clients* of it. Adding a field unilaterally on the worker side without
updating the `.x` definition produces a build that compiles for the
worker but mismatches the on-wire layout the coordinator decodes. SunRPC
will deserialize the next field as garbage, yielding wrong job IDs or
nonsense task counts. Always change the `.x` file first, regenerate
stubs on both sides, then change the C code that uses the new field.

</details>
