# gRPC Lab

Official handout: <https://cs162.org/static/hw/lab-grpc-rs/>

## Introduction

gRPC is the Rust counterpart to SunRPC: protobuf-defined services compile to
Rust client and server stubs that work over HTTP/2. This lab walks you through
a small key/value store implemented with `tonic` and `prost`. You will fill
in the client helpers (`example`, `echo`, `put`, `get`) and the server
handlers behind them. The lab is graded as part of HW 5 (Rust) and is worth
5% of that homework's score.

## Getting Started

You need Rust (via `rustup`) and CMake ≥ 3.20 installed locally. Compiling on
your own machine is much faster than inside the Docker workspace.

```sh
cd ~/code/personal
git pull staff main
cd lab-grpc-rs
cargo build
```

Layout:

| Path                | Role                                          |
| ------------------- | --------------------------------------------- |
| `proto/`            | Protobuf service definition.                  |
| `build.rs`          | Drives `tonic-build` to generate stubs.       |
| `src/server.rs`     | Server-side handler implementations.          |
| `src/client.rs`     | Client helpers used by tests and the CLI.     |
| `src/bin/server.rs` | Server binary entry point (`do not modify`).  |
| `src/bin/client.rs` | Client CLI binary.                            |
| `src/test.rs`       | Round-trip tests (`do not modify`).           |
| `tests/smoke.rs`    | `cargo test --test smoke` smoke checks.       |

The fixed server address is `127.0.0.1:10162` (`SERVER_ADDR` in `lib.rs`).
Start the server in one terminal and the client in another:

```sh
cargo run --bin server &
cargo run --bin client example 1     # expect: 2
```

## Tasks

### Protocol

In `proto/kv_store.proto`, declare the `Example`, `Echo`, `Put`, and `Get`
RPCs along with their request and response messages. `build.rs` regenerates
the Rust stubs on every `cargo build`.

### Server

Implement the `KvStore` service in `src/server.rs`. `Example` is the model
(returns `input + 1`). For `Put` and `Get`, hold a `tokio::sync::Mutex`
around an in-memory `HashMap<Vec<u8>, Vec<u8>>`.

### Client

Implement `example`, `echo`, `put`, and `get` in `src/client.rs`. Each
helper opens a `tonic` channel to `SERVER_ADDR`, calls the corresponding RPC,
and returns the response (or propagates the error via `anyhow::Result`).

## Testing

```sh
make test           # cargo test --test smoke
cargo test          # also runs src/test.rs round-trip tests
```

`make test` runs only the smoke suite (`--help` works for the client, the
server binary built). The round-trip tests in `src/test.rs` need a running
server and a complete implementation; start the server first and re-run
`cargo test` once your code compiles.

## Submission

Push `lab-grpc-rs/` to your personal repository before the lab deadline.

## Self-check

Before submitting, take a stab at these. Full answers in
[`STUDY.md`](STUDY.md).

- What advantage does protobuf give you over XDR for *schema evolution*?
- Why is `tonic-build` invoked from `build.rs` instead of checking generated
  stubs into the repo?
- When should a missing-key response be `Status::not_found` rather than
  `Ok(None)` inside a response message?
- What is the difference between caching a `Channel` and caching the
  per-RPC stub, and which one matters for performance?

## References

- Official handout: <https://cs162.org/static/hw/lab-grpc-rs/>
