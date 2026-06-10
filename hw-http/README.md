# HW 3: HTTP Server (C)

Official handout: <https://cs162.org/static/hw/hw-http/>

## Introduction

You will implement an HTTP/1.0 server in C. The server must accept `GET`
requests for files inside a chosen document root, serve directory index pages
(or generate listings when no `index.html` exists), proxy requests upstream
when configured, and survive concurrent clients under several execution
models: a single-threaded baseline, one fork per connection, one thread per
connection, and a fixed-size worker pool.

## Getting Started

```sh
cd ~/code/personal
git pull staff main
cd hw-http
make
./httpserver --files www --port 8000
```

| Binary         | Concurrency model         | Built from                          |
| -------------- | ------------------------- | ----------------------------------- |
| `httpserver`   | single-threaded, blocking | `httpserver.c` with `-DBASICSERVER` |
| `forkserver`   | one child per connection  | `-DFORKSERVER`                      |
| `threadserver` | one thread per connection | `-DTHREADSERVER`                    |
| `poolserver`   | fixed-size thread pool    | `-DPOOLSERVER`                      |

`libhttp.c/.h` provide request/response helpers; `wq.c/.h` is a thread-safe
work queue you will need for `poolserver`.

## Tasks

### Socket

Create a TCP socket, bind it, mark it `SO_REUSEADDR`, and start listening.
The skeleton has placeholders for the bind/listen flow inside
`serve_forever` — wire them up so the server accepts connections on `--port`.

### GET request

Parse the request line, extract the method and path, reject anything other
than `GET`, and resolve the path against `--files`. Reject `..` path
traversal. For files, send status `200 OK`, an appropriate `Content-Type`,
the `Content-Length`, and the body. For missing files, send `404 Not Found`.

### Directories

If the resolved path is a directory:

- If it contains `index.html`, serve that file.
- Otherwise, generate an HTML listing with one anchor per entry.

### Proxy

When `--proxy host:port` is supplied, open a connection to the upstream and
shuttle bytes both ways with two helper threads. The server must keep working
for non-proxied paths.

### Servers

Add concurrency to `forkserver`, `threadserver`, and `poolserver` by
implementing the `dispatch` callback for each. `poolserver` should pre-spawn
`--num-threads` workers that pull tasks from the `wq_t` work queue.

### Performance (EC)

Compare throughput across the four variants. The handout has suggestions for
tooling (`ab`, `wrk`).

## Testing

```sh
make test
```

Default tests confirm every binary links and prints a Usage message. Once
your server accepts connections, run the integration suite that starts each
variant on an ephemeral port and curls it:

```sh
RUN_FULL=1 make test
```

Add fixtures (small text files, nested directories) to `www/` and assertions
to `tests/run.sh`. Cover at least `200`, `404`, directory listings, the
proxy path, and multiple concurrent clients.

## Submission

Push `hw-http/` to your personal repository. The course autograder exercises
each server variant and the proxy. See the [Submission
page](https://cs162.org/static/hw/hw-http/docs/submission/) for the up-to-date
deadline and grading breakdown.

## Self-check

Before submitting, take a stab at these. Full answers in
[`STUDY.md`](STUDY.md).

- Name two `socket`/`bind`/`listen` mistakes that surface as
  `Error accepting socket: Invalid argument`.
- After `fork()` in `forkserver`, which fd does the parent close, and which
  does the child close?
- Why is `strstr(path, "..")` not a sufficient path-traversal check?
- In proxy mode, how do you distinguish "upstream closed" from "client
  closed" without truncating the response?

## References

- Official handout: <https://cs162.org/static/hw/hw-http/>
- Socket task: <https://cs162.org/static/hw/hw-http/docs/tasks/socket/>
