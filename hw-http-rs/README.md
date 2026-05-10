HW HTTP RS
==========

Overview
--------

This homework implements an HTTP server in Rust. It uses Tokio for async I/O,
Clap for argument parsing, and helper modules for HTTP responses and request
statistics.

Key files
---------

- `Cargo.toml`: Rust package and dependencies.
- `src/main.rs`: binary entry point.
- `src/args.rs`: command-line argument parsing.
- `src/http.rs`: HTTP response helpers and MIME type logic.
- `src/server.rs`: server and request handling.
- `src/stats.rs`: response-code statistics.
- `src/tests/`: current Rust tests.
- `www/`: static files for manual server testing.

Build
-----

```sh
cd hw-http-rs
cargo build
```

Local test plan
---------------

Run the Rust tests:

```sh
cargo test
```

Run the server manually:

```sh
cargo run -- --files www --port 8000
```

From another terminal:

```sh
curl -i http://127.0.0.1:8000/
curl -i http://127.0.0.1:8000/my_documents/wholesome_facts.txt
curl -i http://127.0.0.1:8000/not-found
```

Test completeness review
------------------------

Current status: partial. The repository has 12 Rust test functions across
`args`, `http`, and `stats`. These are useful helper-level tests, but they are
not a complete HTTP server test suite.

What is currently covered:

- `Args::default` and manual `Args` construction.
- MIME type mapping for common file extensions.
- HTTP start-line and header-ending helper behavior.
- `Stats` construction, incrementing, sorted output, debug formatting, and
  shared `StatsPtr` increments.

Important gaps:

- No integration test starts the server and sends real HTTP requests.
- No tests for file serving, directory requests, missing files, malformed
  requests, path traversal, or concurrent clients.
- No tests verify that statistics are updated after actual requests.
- Several implementation files still contain `todo!`, so failing tests are
  expected until those parts are implemented.

Recommended missing tests
-------------------------

- Add Tokio integration tests that bind the server to a temporary port and send
  real HTTP requests.
- Add response assertions for status line, headers, body, MIME type, and content
  length.
- Add missing-file and malformed-request tests.
- Add concurrent-client tests that also verify `Stats` updates.
