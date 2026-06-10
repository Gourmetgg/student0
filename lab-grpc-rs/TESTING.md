# gRPC Lab — Writing the Test Suite

Companion to `tests/smoke.rs` and `src/test.rs`. Read
[`docs/testing-tutorial.md`](../docs/testing-tutorial.md) first.

The lab ships with a complete round-trip test suite in `src/test.rs`
(marked "do not modify"). Your job is to make those tests pass, plus
add coverage for the cases the staff suite doesn't exercise.

## What you're testing

| Feature                                | Test type        |
| -------------------------------------- | ---------------- |
| Client binary `--help` exits 0         | smoke            |
| Server binary builds                   | smoke            |
| `example(1).await == 2`                | round-trip       |
| `echo(s).await == s` for various `s`   | round-trip       |
| `put(k, v); get(k) == v`               | round-trip       |
| `get` on missing key returns `Err`     | failure path     |
| Binary keys/values round-trip          | round-trip       |
| Large values (≥ 1 MB) round-trip       | size sweep       |
| Concurrent `put` from N tasks          | concurrency      |
| Server rejects invalid requests        | failure path     |

## Recipe

1. **Smoke** (already in `tests/smoke.rs`). Client `--help`, server
   binary exists.
2. **Make `src/test.rs` pass.** It runs against `SERVER_ADDR =
   127.0.0.1:10162` — start the server first:

   ```sh
   cargo run --bin server &
   cargo test
   kill %1
   ```
   That's the lab's primary acceptance test.
3. **Add concurrent puts.** Spawn 50 tasks that each `put(format!("k-{i}"),
   format!("v-{i}"))`, then verify every key is readable.
4. **Size sweep.** Loop `vec![0u8; n]` for `n` in
   `[1, 1024, 1<<16, 1<<20]`. Catches buffer-size bugs in your
   server.
5. **Negative get.** `get(b"missing".to_vec()).await` should return
   `Err(_)`. Pin which `tonic::Status` variant — `not_found` is the
   conventional answer.
6. **Server lifecycle.** A second integration test starts the server
   in the same process via `tokio::spawn`, runs a put/get, and
   asserts the server task is still healthy. This catches server
   panics that the system-process test would hide.

## In-process server pattern

The fixed `SERVER_ADDR = 127.0.0.1:10162` is awkward for parallel
tests. Add a constructor that takes a bind address:

```rust
// in src/server.rs
pub async fn start_at(addr: SocketAddr) -> Result<()> { ... }
```

Then your integration test:

```rust
#[tokio::test]
async fn put_then_get() {
    let addr = "127.0.0.1:0".parse().unwrap();
    let listener = TcpListener::bind(addr).await.unwrap();
    let bound = listener.local_addr().unwrap();
    let _srv = tokio::spawn(async move { serve_on(listener).await });
    // sleep tiny bit or poll for readiness
    let mut c = Client::connect(format!("http://{bound}")).await.unwrap();
    c.put(b"k".to_vec(), b"v".to_vec()).await.unwrap();
    assert_eq!(c.get(b"k".to_vec()).await.unwrap(), b"v");
}
```

The handout says "do not modify" `bin/server.rs` and `test.rs` — but
adding `start_at` to `server.rs` is fine and unblocks the test
parallelism story.

## Try it yourself

1. Run `cargo test` with the server running. Now stop the server
   mid-test. What's the error variant the failing tests report? Is it
   the same as "server never started"? Pin both.
2. Build the size-sweep test. At what size does your server first
   fail? Is the limit configurable in `tonic` (it is — find the
   setting) or in your `Vec<u8>` handling?
3. The staff `test.rs` calls `get` on `k1` and expects `is_err()`
   before any `put`. What happens if your server runs from a previous
   test that put `k1`? Decide: does state leak between test runs?
   Pin with a teardown.
4. `tonic` uses HTTP/2. Use `wireshark` or `grpcurl -plaintext
   127.0.0.1:10162 list` to inspect the actual wire traffic during a
   call. What did you learn that you couldn't see from Rust?
5. Add a `#[tokio::test(flavor = "multi_thread")]` annotation to one
   of your tests. Run it 100 times. Does it ever flake? If yes, the
   bug is in your `tokio::sync::Mutex` usage, not the server logic.

## Common pitfalls

- **`tokio::test` defaults to a single-threaded runtime.** Concurrency
  bugs that need ≥ 2 threads to expose won't surface. Use
  `flavor = "multi_thread"` for the concurrent tests.
- **Port 10162 already in use.** Another test (or your shell from an
  earlier run) holds it. `lsof -i :10162` to find the culprit.
- **`Status::not_found` vs `Ok(empty_vec)`.** Decide the convention
  for "missing key" and stick to it. The staff `test.rs` uses
  `is_err()` — be compatible.
- **HTTP/2 buffering.** A `put` followed immediately by `get` may
  arrive at the server in the same HTTP/2 frame. Your handler must
  not assume serial ordering across calls.
- **Server bound to wrong interface.** `127.0.0.1` is reachable only
  from the same host; binding to `0.0.0.0` is needed if you test from
  a Docker container into the host.
