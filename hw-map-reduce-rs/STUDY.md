# HW 5: Understanding Check (Rust)

Self-check questions for HW 5 (Rust). Written by the maintainers of this
repo, not the CS 162 staff.

## 1. The Rust version uses `tonic` (gRPC over HTTP/2). What does HTTP/2 give you over SunRPC for free, and what costs come with it?

<details><summary>Answer</summary>

For free: multiplexed streams on a single TCP connection (one heartbeat
stream and many task streams without head-of-line blocking), framed
flow-controlled messages, TLS as a first-class option, deadlines /
cancellation as part of the protocol, and reflection-friendly
serialization (protobuf). Costs: a much larger dependency surface
(`tonic`, `prost`, `hyper`, `http`, `rustls`), longer compile times,
HTTP/2 framing overhead per message, and a heavier mental model — async
streams, futures cancellation, and `Pin` show up where SunRPC was just a
blocking call.

</details>

## 2. The coordinator holds the cluster state behind an `Arc<Mutex<State>>`. Why is this safe under Tokio when the C version needed a `pthread_mutex_t`?

<details><summary>Answer</summary>

Conceptually it's the same lock — a one-at-a-time critical section. The
Rust difference is that `Mutex<T>` *owns* the protected `T` and the only
way to access it is via `lock()`, which returns a guard. Forgetting to
take the lock fails to compile. Under Tokio you usually want
`tokio::sync::Mutex` rather than `std::sync::Mutex` for any guard that
crosses `.await`, because a sync mutex held across `.await` can deadlock
the executor (one task parks, no thread can drop the guard).

</details>

## 3. A worker registers, the coordinator returns a worker ID. Why does the *coordinator* assign the ID and not the worker pick its own (e.g., UUID)?

<details><summary>Answer</summary>

A coordinator-assigned ID gives a dense small-integer space (1, 2, 3…)
that fits in a `u32` and is cheap to index into a `Vec`. It also means
the coordinator can enforce uniqueness without a clock or a hash
collision check. The downside is that worker registration has to round
trip before the worker can do anything. The trade-off is fine for HW 5;
production systems often use coordinator-assigned IDs for the same
reasons (Hadoop, Spark).

</details>

## 4. The handout uses `tokio::time::sleep` between heartbeats. Why is that better than `std::thread::sleep` inside an `async fn`?

<details><summary>Answer</summary>

`std::thread::sleep` blocks the *OS thread* the task is running on,
preventing every other task on the same Tokio worker from making
progress for the duration. `tokio::time::sleep` returns a future that
yields control back to the executor; the runtime parks the timer in a
priority queue and wakes the task when it expires. Under load,
`thread::sleep` can stall the entire heartbeat path for seconds; the
Tokio version stays responsive.

</details>

## 5. Reduce tasks deserialize map output from disk. What is the right `serde` format choice for that and why?

<details><summary>Answer</summary>

`bincode` (or another compact, schema-on-write binary format like
`postcard`). JSON is human-readable but ~3-10× slower to parse and
inflates intermediate files; YAML/TOML are even worse. The map output
is *internal* to the job — no human needs to read it. Bincode encodes
length-prefixed strings and structs in a stable layout, which means
your reduce can `bincode::deserialize_from(&mut file)` in a tight loop.
The Cargo dependency is already in this crate.

</details>

## 6. The autograder runs jobs that include a deliberate worker crash. What runtime-level mechanism (not your code) gives the coordinator the signal that the worker died?

<details><summary>Answer</summary>

The gRPC stream the worker was holding (heartbeats or its task stream)
closes when the TCP connection drops. `tonic` surfaces that as a
`Status::cancelled` / connection error on the next `await`. The
coordinator's heartbeat task sees a missing tick or an explicit error,
flags the worker `dead`, and re-queues its task. You should not rely
*only* on the explicit-error path: a hung worker that does not drop its
TCP socket needs a heartbeat timeout to detect.

</details>

## 7. `cargo test --test smoke` runs in a separate binary from your unit tests. Why does the test framework segregate integration and unit tests, and what is the practical consequence for crate visibility?

<details><summary>Answer</summary>

Integration tests link against the crate as if they were an external
user, so they can only see `pub` items — that exercises your public API
the way a downstream user will. Unit tests live inside `src/` and can
poke at private functions and modules, so they can target tight
invariants. Putting both in the same binary would let integration tests
reach internals and erode the boundary. The practical consequence: if
your integration smoke test "needs" to import `crate::worker::internal`,
that is a sign to widen the public surface or push the test into `src/`.

</details>
