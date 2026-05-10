HW HTTP
=======

Overview
--------

This homework implements a C HTTP server. It includes basic file serving,
directory listing, proxy support, and multiple concurrency models.

Key files
---------

- `Makefile`: builds `httpserver`, `forkserver`, `threadserver`, and
  `poolserver`.
- `httpserver.c`: request handling, file serving, proxying, and concurrency
  paths.
- `libhttp.c` and `libhttp.h`: HTTP parsing and response helpers.
- `wq.c` and `wq.h`: worker queue support for the thread-pool server.
- `www/`: static files for manual server testing.

Build
-----

```sh
cd hw-http
make
```

Local test plan
---------------

Run one server variant:

```sh
./httpserver --files www --port 8000
```

From another terminal:

```sh
curl -i http://127.0.0.1:8000/
curl -i http://127.0.0.1:8000/my_documents/wholesome_facts.txt
curl -i http://127.0.0.1:8000/not-found
```

Repeat the same curl checks for each concurrency variant:

```sh
./forkserver --files www --port 8000
./threadserver --files www --port 8000
./poolserver --files www --port 8000 --num-threads 4
```

Test completeness review
------------------------

Current status: incomplete. No automated HTTP test script or unit-test harness
was found for the C implementation. The curl commands are smoke tests only.

What is currently covered:

- Compilation of all server variants.
- Manual GET requests for static files.
- Manual comparison across process, thread, and thread-pool variants.

Important gaps:

- No automated tests for HTTP status codes, headers, content length, MIME types,
  directory listing, missing files, bad requests, or proxy behavior.
- No concurrency stress tests for `forkserver`, `threadserver`, or `poolserver`.
- No unit tests for the worker queue.
- No tests for path traversal or malformed request handling.

Recommended missing tests
-------------------------

- Add a shell or Python integration test that starts each server on a temporary
  port, sends HTTP requests, validates status lines and headers, and shuts the
  server down.
- Add tests for directory listing and 404 responses.
- Add concurrent request tests using `curl`, `ab`, `wrk`, or a small custom
  client.
- Add focused worker-queue tests for push, pop, shutdown, and concurrent access.
