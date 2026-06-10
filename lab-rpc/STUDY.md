# RPC Lab: Understanding Check

Self-check questions for the RPC lab. Written by the maintainers of this
repo, not the CS 162 staff.

## 1. What does `rpcgen` actually do for you, and what would the lab look like if you wrote SunRPC by hand?

<details><summary>Answer</summary>

`rpcgen` reads the `.x` interface description and emits four files:
client stubs (the `_clnt.c` calls the client invokes), server stubs (the
`_svc.c` dispatch table that decodes a request and calls your handler),
the XDR marshalling code (`_xdr.c` for every struct in the `.x`), and a
shared header. Doing it by hand means writing all of the above manually
— picking an RPC number, defining a request/response struct layout
including endianness, writing decode/encode for every field, registering
with `portmap`, and wiring the dispatch by hand. `rpcgen` collapses that
into one declaration per RPC.

</details>

## 2. SunRPC uses `rpcbind` (the modern name for `portmap`). What problem does `rpcbind` solve?

<details><summary>Answer</summary>

SunRPC services pick a port dynamically at startup; clients do not know
which port to connect to. `rpcbind` listens on a fixed port (111) and
maintains a mapping from `(program number, version) → port`. The server
registers its dynamic port with `rpcbind` on startup; clients ask
`rpcbind` for the port and then connect directly. Without `rpcbind`
running, clients fail with "RPC: Program not registered" even though
the server process is alive.

</details>

## 3. The `.x` file calls out RPC numbers in a specific range (typically `0x20000000–0x3fffffff` for user-defined services). Why are the ranges meaningful?

<details><summary>Answer</summary>

SunRPC partitions the 32-bit program-number space among Sun-assigned
services, site-specific services, "transient" (user) services, and a
reserved range. Using a transient number means you do not collide with
NFS, mountd, or any other registered protocol on the same host. Picking
a fixed transient number for the lab also means students collaborating
on the same machine can grep for `rpcinfo -p | grep <num>` to find each
other's stale servers.

</details>

## 4. The `EXAMPLE` RPC is fully implemented. What is the pattern it demonstrates that you must follow for `ECHO`, `PUT`, and `GET`?

<details><summary>Answer</summary>

Three things: (a) the handler name is `<rpc>_<version>_svc` (e.g.
`example_1_svc`), (b) the handler returns a *pointer to static storage*
because the stubs copy the value out before the next call — never return
the address of a stack local, (c) the handler takes `(arg, request_t)`
and returns `result_t *` (or `void *` for `void` RPCs). Your ECHO, PUT,
and GET handlers must match all three or `rpcgen` won't link the dispatch
table.

</details>

## 5. Why does returning a pointer to a stack local in an `_svc` handler "work in testing" but fail under load?

<details><summary>Answer</summary>

Right after the handler returns, the stack frame is still in memory and
the bytes are intact, so a single-threaded local test reads the right
value and the bug is invisible. Under concurrent load, another handler
overwrites that stack slot before the marshaller serializes the result,
so the client sees garbage or a crash. Use `static` storage (single
threaded), `thread_local`, or have the caller pass an output buffer.

</details>

## 6. What is the right data structure for the server's KV store, and why is `GHashTable` (from glib, already linked here) a reasonable pick?

<details><summary>Answer</summary>

You need O(1) average insert / lookup keyed on a variable-length byte
buffer with an arbitrary-byte value. A hash table is the obvious match.
`GHashTable` is already linked into this lab, supports user-provided
hash and equality functions for `Vec<u8>`-style keys, and handles
collisions for you. The alternative (writing a hash table or using a
linked list) is fine for the lab's volume but is not the point of the
exercise — the point is the RPC plumbing.

</details>

## 7. Your server returns `RPC: Authentication error` to the client. Where is that coming from and how do you fix it?

<details><summary>Answer</summary>

SunRPC handles authentication at the protocol level; the default `AUTH_NULL`
identifies the caller as "nobody". If your `.x` declares a stricter auth
flavor (or you call `clnt_create` with `AUTH_UNIX` on the client but
the server expects `AUTH_NULL`, or vice versa), the per-call dispatch
rejects the request with an auth error. Match the auth on both ends —
for this lab, leave both at the default `AUTH_NULL` and remove any
`auth_create`/`auth_destroy` calls.

</details>
