# HW 3 (C) — Writing the Test Suite

Companion to `tests/run.sh`. Read
[`docs/testing-tutorial.md`](../docs/testing-tutorial.md) first.

## What you're testing

| Feature                                  | Test type           |
| ---------------------------------------- | ------------------- |
| Each variant prints usage on no args     | shape check         |
| `GET /` returns 200 + body               | curl, body diff     |
| `GET /missing` returns 404               | status check        |
| Correct `Content-Type` per extension     | header check        |
| Correct `Content-Length` for body bytes  | header check        |
| Directory with `index.html` serves index | body diff           |
| Directory without index gets listing     | substring check     |
| Path traversal (`/../etc/passwd`) blocked | status check       |
| Proxy mode shuttles bytes both ways      | curl through proxy  |
| Concurrent clients all get 200           | xargs / parallel    |
| `forkserver` reaps zombies               | `ps` after the test |
| `poolserver` handles N > num_threads     | concurrent stress   |

## Recipe

1. **Build smoke + usage** (already in `tests/run.sh`).
2. **Single-client GET /.** Start `httpserver` on an ephemeral port,
   `curl -i http://127.0.0.1:$PORT/`, assert `HTTP/1.0 200 OK` in the
   response. Trap kills the server.
3. **404 path.** `GET /no-such-file`. Status line `404`. Body should
   look like a 404.
4. **Headers exactly.** Use `curl -D headers.txt` and grep for
   `Content-Type: text/html` and a numeric `Content-Length`. Verify
   `Content-Length` matches the actual body length (`wc -c < body`).
5. **Directory + index.** `www/` has `index.html`. `GET /` should
   serve it. Don't assert the literal text past one stable substring —
   the fixture file may evolve.
6. **Directory listing.** Add a fixture directory `www/empty-dir/`
   without an index. `GET /empty-dir/` should produce an HTML body
   containing the directory's name.
7. **Path traversal.** `GET /../Makefile` and `GET /%2e%2e/Makefile`.
   Both must NOT return `200`. Pin "404 or 403" — either is fine if
   it's consistent.
8. **Concurrent clients.** `seq 1 50 | xargs -I_ -P 50 curl -s -o
   /dev/null -w "%{http_code}\n" http://...`. All 50 lines should be
   `200`. Repeat for `forkserver`, `threadserver`, `poolserver`.
9. **Proxy.** Start `httpserver` in proxy mode pointing at a tiny
   throw-away origin (`python3 -m http.server`). `curl` through the
   proxy and compare to direct fetch.

## Each variant gets the same battery

Reuse the same test functions for `httpserver`, `forkserver`,
`threadserver`, `poolserver`. Take the binary name as a parameter:

```sh
run_battery() {
  local bin="$1"
  local port=$(( (RANDOM % 1000) + 18000 ))
  "$ROOT/$bin" --files "$ROOT/www" --port "$port" >/tmp/srv.log 2>&1 &
  local srv=$!
  trap "kill $srv 2>/dev/null; wait 2>/dev/null" EXIT
  wait_ready "127.0.0.1" "$port"
  # ... 200, 404, headers, traversal, concurrent ...
  kill "$srv"; wait
}

for v in httpserver forkserver threadserver poolserver; do run_battery "$v"; done
```

## wait_ready helper

```sh
wait_ready() {
  local host="$1" port="$2"
  for _ in $(seq 1 50); do
    if curl -s --max-time 1 "http://$host:$port/" >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.1
  done
  return 1
}
```

## Try it yourself

1. The starter prints `Error accepting socket: Invalid argument` in a
   tight loop. Write a test that catches that *symptom* (look at
   stderr) rather than just "server can't connect." Why is the second
   wording wrong?
2. Implement the `Content-Length` test. Now build a fixture that is
   exactly 1 byte. Does your server emit `Content-Length: 1` or
   `Content-Length: 2` (off-by-one)? Predict before running.
3. Write the proxy test using two `httpserver` processes — one serving
   files, one proxying to the first. The test should not need a
   network. What port pair did you pick and why?
4. The concurrent test runs 50 `curl`s. Lower the load to 5 — does the
   test still find the bug you saw at 50? Raise to 500 — does the test
   start flaking? Find the threshold and document it.
5. `forkserver` should reap zombies. Add a check after the load test:
   `ps -p $(pgrep -P $srv)` should produce nothing. Why is `wait`
   inside the parent the right fix, and what's the trade-off with
   `signal(SIGCHLD, SIG_IGN)`?

## Common pitfalls

- **Curl reads the proxy from the environment.** Always pass
  `--noproxy '*'` or your test goes through the system proxy and
  bypasses your server.
- **`HTTP/1.0` vs `HTTP/1.1`.** The handout pins 1.0. Match the version
  in your asserts — curl will accept either.
- **Server log on stdout vs stderr.** `>/tmp/srv.log 2>&1` keeps your
  test output clean. Otherwise stderr noise mixes with the assertions.
- **`SO_REUSEADDR` is not enough on macOS.** Use `SO_REUSEPORT` too if
  your tests run on a Mac and the previous run left a `TIME_WAIT`
  socket.
- **Port collisions in parallel tests.** Pick a per-test port from
  `$RANDOM` or, better, bind to port 0 and read back the OS-assigned
  port from `getsockname`.
