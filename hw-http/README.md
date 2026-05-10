HW 3: HTTP Server in C
======================

Official reference:

- <https://cs162.org/static/hw/hw-http/>
- <https://cs162.org/static/hw/hw-http/docs/tasks/socket/>

Assignment goals
----------------

This homework implements an HTTP server in C. The official CS 162 task set
covers socket setup, request parsing, `GET` handling, directory responses,
proxying, multiple server variants, thread-pool support, and performance
measurement.

The repository contains several server binaries so the same request-handling
behavior can be validated under single-process, fork-per-connection,
thread-per-connection, and thread-pool execution models.

Key implementation areas
------------------------

- `httpserver.c`: server startup, request handling, file serving, proxy path,
  and concurrency-specific behavior.
- `libhttp.c` and `libhttp.h`: HTTP request and response helpers.
- `wq.c` and `wq.h`: work queue for the thread-pool server.
- `www/`: static file tree for manual testing.
- `Makefile`: builds `httpserver`, `forkserver`, `threadserver`, and
  `poolserver`.

Build and run
-------------

```sh
cd hw-http
make
./httpserver --files www --port 8000
```

From another terminal:

```sh
curl -i http://127.0.0.1:8000/
curl -i http://127.0.0.1:8000/my_documents/wholesome_facts.txt
curl -i http://127.0.0.1:8000/not-found
```

Repeat the same checks for the concurrency variants:

```sh
./forkserver --files www --port 8000
./threadserver --files www --port 8000
./poolserver --files www --port 8000 --num-threads 4
```

Current test inventory
----------------------

No checked-in automated HTTP test harness was found for the C server. The
current coverage is manual `curl` smoke testing only.

Completeness assessment
-----------------------

Coverage is incomplete. HTTP behavior should be verified over real sockets,
because parser bugs, header formatting bugs, file I/O errors, and concurrency
bugs often do not appear in compilation-only checks.

Missing coverage includes:

- Socket bind/listen/accept startup on all server variants.
- Valid `GET` for files and directories.
- Status codes for `200`, `400`, `403`, `404`, and `501` where applicable.
- Headers such as `Content-Length`, `Content-Type`, `Connection`, and response
  terminator formatting.
- MIME type selection.
- Directory listing behavior.
- Path traversal rejection.
- Malformed request handling.
- Proxy mode.
- Worker-queue behavior in `poolserver`.
- Concurrent clients and performance regression checks.

Detailed missing-test prompts
-----------------------------

1. Add `tests/http_smoke.sh`:

   - Build with `make`.
   - Pick an unused port.
   - Start a server in the background.
   - Wait until the port accepts connections.
   - Run `curl` checks.
   - Kill the server in a `trap` on exit.

   Suggested structure:

   ```sh
   server="$1"
   port="${PORT:-18080}"
   "$server" --files www --port "$port" &
   pid="$!"
   trap 'kill "$pid" 2>/dev/null || true' EXIT
   ```

2. Add status-line tests for every server variant:

   ```sh
   curl -sS -i "http://127.0.0.1:$port/" | grep -q "HTTP/1.0 200"
   curl -sS -i "http://127.0.0.1:$port/not-found" | grep -q "HTTP/1.0 404"
   ```

   Run these against `httpserver`, `forkserver`, `threadserver`, and
   `poolserver`.

3. Add file-body and header tests:

   - Request `www/my_documents/wholesome_facts.txt`.
   - Assert the body contains a known line from the fixture.
   - Assert `Content-Length` matches the fixture byte length.
   - Assert `Content-Type` matches the extension.

4. Add directory tests:

   - Request `/`.
   - Assert the response is `200`.
   - Assert the body references expected entries from `www/`.
   - Request a directory without a trailing slash if the assignment specifies a
     redirect or normalized response, and assert that behavior.

5. Add malformed request tests using `nc` or a small Python client:

   ```sh
   printf "BADREQUEST\r\n\r\n" | nc 127.0.0.1 "$port"
   printf "POST / HTTP/1.0\r\n\r\n" | nc 127.0.0.1 "$port"
   ```

   Assert the documented error status and confirm the server keeps accepting
   later requests.

6. Add path traversal tests:

   ```sh
   curl -sS -i "http://127.0.0.1:$port/../Makefile"
   curl -sS -i "http://127.0.0.1:$port/%2e%2e/Makefile"
   ```

   Assert that files outside `www/` are not served.

7. Add concurrency tests:

   ```sh
   seq 1 50 | xargs -n1 -P10 -I{} curl -fsS "http://127.0.0.1:$port/" >/dev/null
   ```

   Run this for `forkserver`, `threadserver`, and `poolserver`. The test should
   fail on any non-2xx response, crash, or hang.

8. Add `wq` unit tests:

   Create `tests/test_wq.c` that links against `wq.c` and checks:

   - Queue initializes empty.
   - Push followed by pop returns the same pointer.
   - Multiple items preserve FIFO order.
   - Multiple producer and consumer threads do not lose items.
   - Shutdown or destroy behavior does not leave waiting threads stuck.

9. Add proxy tests:

   - Start a local backend with `python3 -m http.server 19090`.
   - Start the homework server in proxy mode.
   - Request through the homework server.
   - Assert that backend content is returned and that backend failure produces a
     documented error response.

Suggested `make test` target
----------------------------

Add a `test` target that runs `tests/http_smoke.sh` for each binary. Keep a
separate `make perf` or `make stress` target for high-concurrency and benchmark
runs so the default test remains fast.
