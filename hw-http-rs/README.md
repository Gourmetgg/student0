HW 3: HTTP Server in Rust
=========================

Official reference:

- <https://cs162.org/static/hw/hw-http-rs/>
- <https://cs162.org/static/hw/hw-http-rs/docs/requests/>

Assignment goals
----------------

This homework implements the CS 162 HTTP server in Rust. It mirrors the C HTTP
homework while using Rust libraries and async I/O. The official task set covers
argument parsing, socket handling, request parsing, `GET` responses, directory
handling, response-code statistics, and performance-oriented testing.

Key implementation areas
------------------------

- `src/main.rs`: binary entry point and server startup.
- `src/args.rs`: command-line argument parsing.
- `src/http.rs`: response formatting, headers, status lines, and MIME helpers.
- `src/server.rs`: socket accept loop and request handling.
- `src/stats.rs`: shared response-code counters.
- `src/tests/`: current helper-level Rust tests.
- `www/`: static file tree for manual server testing.

Build and run
-------------

```sh
cd hw-http-rs
cargo build
cargo test
cargo run -- --files www --port 8000
```

From another terminal:

```sh
curl -i http://127.0.0.1:8000/
curl -i http://127.0.0.1:8000/my_documents/wholesome_facts.txt
curl -i http://127.0.0.1:8000/not-found
```

Current test inventory
----------------------

The repository currently has helper-level Rust tests in `src/tests/`:

- `args.rs`: default argument behavior and manual construction.
- `http.rs`: MIME type helpers and response helper formatting.
- `stats.rs`: counter initialization, increments, sorted output, debug
  formatting, and shared stats updates.

These tests are useful, but they do not start the server or send real HTTP
requests.

Completeness assessment
-----------------------

Coverage is partial. The helper tests protect small functions, but the main
assignment behavior lives at the socket and request-handler boundary.

Missing coverage includes:

- `parse_request` behavior for valid, invalid, partial, and unsupported
  requests.
- Real file serving over TCP.
- Directory responses.
- Missing-file and forbidden-path behavior.
- Header and body correctness for real responses.
- Response-code statistics after real requests.
- Concurrent clients.
- Graceful handling of malformed clients that disconnect early.

Detailed missing-test prompts
-----------------------------

1. Add request-parser unit tests:

   In `src/tests/http.rs` or a new `src/tests/requests.rs`, create cases for:

   - `GET /index.html HTTP/1.0\r\n\r\n`
   - `GET / HTTP/1.1\r\nHost: localhost\r\n\r\n`
   - `POST / HTTP/1.0\r\n\r\n`
   - Empty input.
   - A request line with too few fields.
   - A path containing `..`.

   Assert the exact parsed method, path, and error type expected by the
   implementation.

2. Add a Tokio integration test under `tests/server_integration.rs`:

   - Create a temporary directory.
   - Write `index.html` and another small file.
   - Bind the server to port `0` or otherwise allocate a free port.
   - Connect with `tokio::net::TcpStream`.
   - Send a raw HTTP request.
   - Read the full response and assert status line, headers, and body.

3. Add real `GET` response checks:

   ```text
   GET /index.html HTTP/1.0\r\n\r\n
   ```

   Assert:

   - Status contains `200`.
   - `Content-Length` equals the fixture byte length.
   - `Content-Type` matches the extension.
   - Body equals the file contents.

4. Add missing-file and traversal checks:

   ```text
   GET /missing.txt HTTP/1.0\r\n\r\n
   GET /../Cargo.toml HTTP/1.0\r\n\r\n
   ```

   Assert that missing files return the documented not-found status and that
   traversal attempts do not expose files outside the configured root.

5. Add directory checks:

   - Request `/`.
   - Assert either the configured index file or directory listing behavior,
     depending on the implementation path required by the assignment.
   - Request a nested directory fixture and assert stable output.

6. Add stats integration checks:

   - Send two successful requests and one missing-file request.
   - Query or inspect the shared `Stats` object if the server exposes it.
   - Assert the `200` and `404` counters changed by the expected amounts.

7. Add concurrent-client coverage:

   ```rust
   let requests = (0..50).map(|_| tokio::spawn(send_get(port, "/index.html")));
   ```

   Await all tasks and assert every response is successful. This catches
   accidental shared-state locks held too long and request-handler panics.

8. Add disconnect and partial-request coverage:

   - Open a TCP connection and close it without sending a full request.
   - Send `GET / HTTP/1.0\r\n` without the terminating blank line.
   - Assert the server does not panic and still accepts a later valid request.

Suggested commands
------------------

```sh
cargo test
cargo test --test server_integration
cargo test -- --nocapture
```

Keep fast parser/helper tests in the default suite, and keep slower concurrent
server tests in integration tests so they can be isolated when debugging.
