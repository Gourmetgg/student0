# RPC Lab

Official handout: <https://cs162.org/static/hw/lab-rpc/>

## Introduction

Remote Procedure Calls let a client invoke a function that runs on another
machine while making the call site look local. This lab gives you hands-on
experience with `rpcgen`, the SunRPC stub generator, by implementing a small
key/value store. You will define the RPC interface, generate client and
server stubs, and finish the bodies of `ECHO`, `PUT`, and `GET`. The
`EXAMPLE` RPC is fully implemented as a reference.

## Getting Started

Inside the CS 162 Docker workspace:

```sh
cd ~/code/personal
git pull staff main
cd lab-rpc
sudo service rpcbind start   # once per workspace restart
make
```

Layout:

| File                  | Role                                  |
| --------------------- | ------------------------------------- |
| `kv_store.x`          | SunRPC interface description.         |
| `server.c`            | Server-side RPC handlers.             |
| `client.c`            | Client CLI entry point.               |
| `kv_store_client.c/h` | Convenience wrappers for the client.  |

`make` runs `rpcgen kv_store.x` to produce `kv_store.h`, `kv_store_xdr.c`,
`kv_store_clnt.c`, and `kv_store_svc.c`, then links `bin/server` and
`bin/client`.

Run the example end-to-end:

```sh
./bin/server &
./bin/client example 1     # expect: 2
fg                          # bring server back to the foreground
```

## Tasks

### Protocol

In `kv_store.x`, declare the RPC numbers and the request/response types for
ECHO, PUT, and GET. EXAMPLE is already declared as a model. Re-run `make`
after editing this file; it regenerates all stubs.

### Server

Fill in the `_1_svc` functions for ECHO, PUT, and GET in `server.c`. The
example shows the calling convention (`static` storage, return by pointer).
Store keys/values in any in-memory data structure that supports byte-array
keys.

### Client

Add `echo`, `put`, and `get` subcommands to `client.c`. Use the helpers in
`kv_store_client.c/h` so the call sites remain short. Print the server's
response to stdout.

## Testing

```sh
make test
```

The smoke suite confirms `rpcgen` ran, both binaries linked, and the client
does not hang. A live round-trip is gated behind `RUN_FULL=1` because it
requires `rpcbind` to be running:

```sh
sudo service rpcbind start
RUN_FULL=1 make test
```

Extend `tests/run.sh` once your implementation works: assert
`./bin/client put k v` followed by `./bin/client get k` prints `v`, and
that overwrites are visible to subsequent gets.

## Submission

Push `lab-rpc/` to your personal repository before the lab deadline. The lab
is graded as part of HW 5 (worth 5%).

## Self-check

Before submitting, take a stab at these. Full answers in
[`STUDY.md`](STUDY.md).

- What problem does `rpcbind` (formerly `portmap`) solve, and what error do
  you see if it isn't running?
- What pattern does the staff-provided `example_1_svc` demonstrate that
  your `echo`/`put`/`get` handlers must follow?
- Why does returning a pointer to a stack local from an `_svc` handler
  "work in testing" but fail under load?
- Why is `GHashTable` from glib a reasonable pick for the KV store backing
  type?

## References

- Official handout: <https://cs162.org/static/hw/lab-rpc/>
