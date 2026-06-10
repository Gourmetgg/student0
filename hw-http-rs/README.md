# HW 3: HTTP Server (Rust)

Official handout: <https://cs162.org/static/hw/hw-http-rs/>

## Introduction

This homework mirrors HW 3 (C) using Rust and async I/O. You will build an
HTTP/1.0 server with the Tokio runtime that parses `GET` requests, serves
files and directory listings, and tracks per-status-code statistics shared
across tasks. The handout is organised around the same task list as the C
version (sockets → request parsing → directory handling → stats) but the
focus shifts toward correct use of `tokio::net`, `tokio::fs`, and
`tokio::sync` primitives instead of `pthread` and raw `read`/`write`.

## Getting Started

Rust development is much faster locally than inside the course Docker. Make
sure the workspace has `cargo` from `rustup`; the crate pins itself to
`1.66.1` via `rust-toolchain.toml`.

```sh
cd ~/code/personal
git pull staff main
cd hw-http-rs
cargo build
cargo run -- --files www --port 8000
```

Layout:

| Path            | Role                                                  |
| --------------- | ----------------------------------------------------- |
| `src/main.rs`   | Binary entry point.                                   |
| `src/args.rs`   | clap-based CLI parsing.                               |
| `src/http.rs`   | Status lines, headers, MIME lookup, response writers. |
| `src/server.rs` | Async listener and per-connection handler.            |
| `src/stats.rs`  | Shared response-code counters.                        |
| `src/tests/`    | Unit tests for the helpers above.                     |
| `www/`          | Static files used for manual testing.                 |

## Tasks

### Background and Rust

Skim the handout's Rust crash-course pages. You will use `tokio::spawn`,
`Arc<Mutex<...>>`, and `?`-style error propagation throughout.

### Socket

Bind a `TcpListener` on the requested port, accept in a loop, and spawn a
Tokio task per connection. Each task owns its `TcpStream` and runs the
request handler.

### GET requests

Implement `parse_request` in `http.rs`. Reject anything that is not a
well-formed `GET` request line; return an `Err` on partial or malformed
input. In `server.rs`, dispatch on the parsed path: file → `200 OK`,
directory containing `index.html` → that file, other directory → generated
listing, missing path → `404 Not Found`.

### MIME types

Finish `get_mime_type` so common extensions (`.html`, `.css`, `.js`,
`.png`, `.jpg`, `.txt`, ...) map to standard types; everything else falls
back to `application/octet-stream`.

### Statistics

Make `Stats` thread-safe (wrap with `Mutex` or use atomics) and have
`server.rs` call `Stats::incr` for every response status code. Expose
`items()` sorted by status code so the test suite can assert deterministic
output.

## Testing

```sh
make test           # runs the integration smoke test
cargo test          # also runs src/tests/* unit tests
```

`make test` invokes `cargo test --test smoke`, which builds the binary and
asserts `--help` returns cleanly — this passes on the unmodified starter and
is what the repo-level `run_all_tests.sh` runs.

The full `cargo test` includes the helper-level unit tests for `args`,
`http`, and `stats`. Several of those tests panic on `todo!()` until you
finish the implementation; they are designed to walk you through each task in
order.

For end-to-end coverage, start the server on `127.0.0.1:0` from an
integration test and use `reqwest` or `tokio::net::TcpStream` to assert
status codes, headers, and body bytes.

## Submission

Push the `hw-http-rs/` directory to your personal repository. The autograder
runs `cargo test` and the staff integration tests.

## Self-check

Before submitting, take a stab at these. Full answers in
[`STUDY.md`](STUDY.md).

- What is the runtime difference between a Tokio task and an OS thread, and
  why does it matter for a webserver?
- Why is `Arc<Mutex<Stats>>` the standard idiom and why does
  `Rc<RefCell<Stats>>` fail to compile here?
- The crate sets `panic = 'abort'`. What does that change about how a
  panicking task affects the rest of the server?
- Why does `#[tokio::test]` exist — wouldn't `#[test] async fn ...` work?

## References

- Official handout: <https://cs162.org/static/hw/hw-http-rs/>
- Request page: <https://cs162.org/static/hw/hw-http-rs/docs/requests/>
