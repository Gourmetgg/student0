# HW 3 (Rust) — Writing the Test Suite

Companion to `tests/smoke.rs`. Read
[`docs/testing-tutorial.md`](../docs/testing-tutorial.md) first.

## What you're testing

| Feature                                | Test type            |
| -------------------------------------- | -------------------- |
| `Args` defaults parse                  | unit                 |
| `get_mime_type` per extension          | unit table-driven    |
| `parse_request` happy path             | unit                 |
| `parse_request` rejects bad input      | unit, `Err` arm      |
| `start_response`/`send_header` bytes   | unit, byte slice cmp |
| `Stats::incr` then `items()` ordered   | unit                 |
| Server returns 200 for `/`             | integration, TCP     |
| Server returns 404 for missing path    | integration, TCP     |
| Stats reflect responses                | integration, TCP     |
| Concurrent requests don't deadlock     | integration, stress  |

The crate is binary-only; integration tests in `tests/*.rs` cannot
import private modules. Two consequences:

- **Helper-level tests** live inside `src/tests/`. They have full
  access to private items.
- **Integration tests** in `tests/` spawn the binary as a subprocess.
  They test the public CLI surface.

Use both layers.

## Recipe

1. **Smoke** (already in `tests/smoke.rs`). Binary builds and
   `--help` exits 0.
2. **Unit: `Args::default`.** Already in `src/tests/args.rs`. Add one
   case per field — overriding `port`, `files`, `num_threads`
   independently.
3. **Unit: `get_mime_type`.** Table-driven:

   ```rust
   #[test]
   fn mime_table() {
       let cases = [
           ("index.html", "text/html"),
           ("script.js", "application/javascript"),
           ("data.bin", "application/octet-stream"),
       ];
       for (path, want) in cases {
           assert_eq!(get_mime_type(path), want, "for {path}");
       }
   }
   ```
4. **Unit: `parse_request`.** Test the happy path, then test a request
   with missing path, missing method, missing newline. Each `Err`
   variant gets its own test.
5. **Unit: `Stats`.** Insert a few status codes, assert `items()`
   sorted output. If `Stats` is shared via `Arc<Mutex<_>>`, spawn
   threads that all call `incr` and confirm the total at the end.
6. **Integration: server over TCP.** Add a new `tests/server.rs`:

   ```rust
   use std::process::{Command, Stdio};
   use std::net::TcpStream;
   use std::io::{Read, Write};

   #[test]
   fn server_serves_index() {
       let bin = env!("CARGO_BIN_EXE_http_server_rs");
       let mut child = Command::new(bin)
           .args(["--files", "www", "--port", "0"])  // OS picks port
           .stdout(Stdio::piped())
           .spawn().expect("spawn");
       // Read port from stdout, connect, GET, assert 200.
       // Always kill in `Drop` — wrap child in a guard struct.
   }
   ```
   The trickiest part is reading the chosen port back from the
   child. Have the server log `listening on 127.0.0.1:<port>` on
   startup, parse it, then connect.
7. **Concurrent integration.** Use `tokio::task::JoinSet` to spawn 50
   `reqwest` GETs. All should return 200. If your server uses
   `tokio::spawn` per connection, this exercises the concurrency.

## A Drop-based child guard

```rust
struct ChildGuard(std::process::Child);
impl Drop for ChildGuard {
    fn drop(&mut self) {
        let _ = self.0.kill();
        let _ = self.0.wait();
    }
}
```

Without this, a failing assertion leaves the server bound. The next
test run fails because the port is busy — and you blame the new test.

## Try it yourself

1. The starter `Stats::incr` is marked `#[allow(dead_code)]`. Remove
   the attribute. What warning fires, and what does that tell you
   about which integration test you have not written yet?
2. Write a `parse_request` test for `GET / HTTP/2.0` (the version your
   server does not support). Decide: `Err(ParseError::Version)` or
   `Ok(Request { version: 2 })`? Pin your choice with the test.
3. Build a tokio task that holds the `Stats` mutex for 5 seconds.
   Have your integration test fire requests during the hold — does
   anything deadlock? If yes, you held `std::sync::Mutex` across an
   `.await`. (See `docs/testing-tutorial.md` §15.)
4. Compile with `-C overflow-checks=on` and rerun. If any test now
   panics on integer overflow, you have a `usize` wrap somewhere
   important — name it.
5. The crate sets `panic = 'abort'`. Trigger a panic inside one
   request handler and verify with an integration test that the
   *entire* server exits. Why is "abort on panic" reasonable for a
   coursework server, and what would change in a production design?

## Common pitfalls

- **`#[tokio::test]` requires the `macros` Tokio feature.** Already
  enabled here, but a new crate may not have it.
- **`Arc<Mutex<T>>` held across `.await` deadlocks.** Use
  `tokio::sync::Mutex` when the guard crosses an await point. For
  `Stats`, the lock is short-lived so `std::sync::Mutex` is fine —
  but be deliberate.
- **`cargo test` rebuilds the whole crate.** Slow on the course
  Docker. Use `cargo test --test smoke` for the smoke suite,
  `cargo test --bin http_server_rs` for unit tests, and add a
  `make watch` target backed by `cargo-watch` for fast iteration.
- **`tests/smoke.rs` runs the binary; `src/tests/` runs in-process.**
  An assertion that works in one may not work in the other.
- **Integration tests share a single `target/debug/`.** A failing
  port-bind test poisons every subsequent test that uses the same
  port. Always bind to port 0.
