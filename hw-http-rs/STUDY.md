# HW 3: Understanding Check (Rust)

Self-check questions for HW 3 (Rust). Written by the maintainers of this
repo, not the CS 162 staff.

## 1. The C version uses `pthread`; the Rust version uses `tokio::spawn`. What is the fundamental difference between a Tokio task and an OS thread, and why does it matter for a webserver?

<details><summary>Answer</summary>

A Tokio task is a stackless coroutine scheduled by the Tokio runtime onto
a small pool of OS threads; an OS thread has its own kernel stack and is
scheduled by the kernel. A webserver typically has many connections that
spend most of their time waiting on I/O. A task per connection costs a
few hundred bytes; a thread per connection costs ~2 MB of stack and a
kernel-scheduling slot. Spawning 100 000 tasks is routine; spawning
100 000 threads is not. The trade-off is that any `.await` point is a
voluntary yield, so a CPU-bound task can starve the executor unless you
`spawn_blocking`.

</details>

## 2. `Stats` is shared across tasks. Why is `Arc<Mutex<Stats>>` the standard idiom and what goes wrong if you use `Rc<RefCell<Stats>>` instead?

<details><summary>Answer</summary>

`Rc` is single-threaded and not `Send`, `RefCell` is not `Sync`. Tokio
tasks may move between executor threads on every `.await`, so the
borrowed type must be `Send + Sync`. `Arc<Mutex<T>>` provides both: `Arc`
gives thread-safe reference counting, `Mutex` gives interior mutability
with a thread-aware lock. Trying `Rc<RefCell<...>>` will fail to compile
the moment the value crosses an `.await`.

</details>

## 3. `parse_request` returns `Result<Request, _>`. Why is returning `Option<Request>` for a parse error worse, even though both encode "no request"?

<details><summary>Answer</summary>

`Option` collapses every failure into `None`, losing the reason. A real
parser can fail in many ways (incomplete buffer, unsupported method,
malformed header). The server wants to distinguish "need more bytes" from
"client sent garbage" — the first means keep reading, the second means
send `400 Bad Request` and close. `Result<Request, ParseError>` lets the
caller match on the error variant and respond correctly. Use `Option`
only when there is exactly one kind of "not present".

</details>

## 4. The crate sets `panic = 'abort'` in both `[profile.dev]` and `[profile.release]`. What does that change about the server's behavior when one task panics?

<details><summary>Answer</summary>

With the default `panic = 'unwind'`, a panic unwinds the panicking task's
stack and Tokio catches it — the rest of the server keeps running.
With `panic = 'abort'`, the entire process exits on the first panic.
That is a deliberate choice: in production you usually want the
supervisor to restart you cleanly rather than continue with corrupted
state, and abort is slightly faster and produces smaller binaries
(no unwind tables). The cost is that one buggy connection brings down
every other in-flight connection.

</details>

## 5. The test suite uses `tokio::test` to run async tests. Why does the macro exist, and what would `#[test] async fn ...` give you instead?

<details><summary>Answer</summary>

`#[test]` calls the function synchronously. An `async fn` returns a
`Future` that does nothing until polled, so a plain `#[test]` on an async
function would type-check but never actually execute the body — the test
"passes" trivially. `#[tokio::test]` expands to `#[test] fn name() {
let rt = tokio::runtime::Runtime::new().unwrap(); rt.block_on(async {
... }) }`, which actually drives the future to completion under a fresh
runtime.

</details>

## 6. `Stats::items()` returns the entries sorted by status code. Why sort inside the method instead of relying on the caller to sort?

<details><summary>Answer</summary>

The method's contract becomes deterministic: every caller sees the same
order, so the test suite can `assert_eq!` against a literal. If sorting
were the caller's responsibility, you'd see callers that forgot to sort,
test flakes that depend on `HashMap` hash randomization, and bugs that
only reproduce on certain Rust versions. The cost of sorting is O(n log
n) on a small `n` (number of distinct status codes), which is negligible.

</details>

## 7. The starter's `Stats::incr` is marked `#[allow(dead_code)]` and never called from `server.rs`. The compiler warning is your hint — what is the *test design* lesson behind making the helper public *before* the integration code uses it?

<details><summary>Answer</summary>

Test-driven order. The handout lets you implement and unit-test
`Stats::incr` in isolation before you have to plumb it through the async
server. By the time you wire `incr` into `server.rs` the helper already
has assertions saying "this counts correctly". This is the same workflow
the staff want you to use for `parse_request`, `get_mime_type`, and the
response helpers: get unit confidence first, then write the integration
glue. A monolithic implementation skips this step and ships bugs that
are hard to localize.

</details>
