# HW 3: Understanding Check (C)

Self-check questions for HW 3 (C version). Written by the maintainers of
this repo, not the CS 162 staff.

## 1. The skeleton creates the listening socket but the starter cannot accept connections (`Error accepting socket: Invalid argument`). Without reading the source, name two `socket()` / `bind()` / `listen()` mistakes that produce exactly that error message at `accept` time.

<details><summary>Answer</summary>

Two common ones: (a) calling `accept` on a socket that has not been
`listen()`ed on — the kernel returns `EINVAL`. (b) Passing a stale or
zero-initialized `socklen_t *` so the kernel sees a length of 0. A third
classic is calling `bind` with a partially-initialized `sockaddr_in`
(forgot to set `sin_family = AF_INET` or `sin_port = htons(port)`),
which makes `bind` succeed on a garbage address; `accept` then fails
because the socket is in an unusable state.

</details>

## 2. HTTP/1.0 closes the TCP connection after every response. Why does HTTP/1.1 keep-alive change the design of your accept loop, and what bug appears if you forget to handle it?

<details><summary>Answer</summary>

Under HTTP/1.0 you can `read` one request, write one response, and
`close`. Under keep-alive you must loop on the same socket reading
successive requests until the client closes or you time out. If your
HTTP/1.0 server is upgraded to handle keep-alive without that loop, it
will read the *first* request after the first one (which the client
pipelined), interpret the response body of the second request as a new
request line, and either 400 it or hang. Either set `Connection: close`
in every response, or implement the loop properly.

</details>

## 3. Your `forkserver` `fork()`s a child for every connection. What state must the parent close in the child, and what must the child close in the parent?

<details><summary>Answer</summary>

After `accept`, the parent has both the listening fd and the new
connection fd; the child only needs the connection fd. The child should
`close()` the listening fd so it does not hold a reference (otherwise a
SIGHUP on the parent leaves the child still bound to the port). The
parent should `close()` the connection fd after fork, otherwise the
connection stays open from the parent's side and the client never sees
EOF when the child finishes. Both sides should also reap children (or
`signal(SIGCHLD, SIG_IGN)`) to avoid zombies.

</details>

## 4. The thread-pool server uses a `wq_t` work queue. Why is a condition variable the right primitive here instead of a busy loop on `pthread_mutex_trylock`?

<details><summary>Answer</summary>

A condition variable lets the worker block in the kernel until there is
work, so an idle pool consumes 0% CPU. A busy `trylock` spins, eats CPU
proportional to the pool size, and starves the dispatcher trying to enqueue
work. The pattern is: dispatcher locks the queue, pushes the fd, calls
`pthread_cond_signal`, unlocks; worker locks, waits in a `while`-guarded
`pthread_cond_wait` (always re-check the predicate after wake), pops,
unlocks.

</details>

## 5. Your server serves a 1 GB file. With `read(file, buf, 1024); write(socket, buf, 1024)` in a loop, you saturate disk *and* CPU. What syscall would fix this and why?

<details><summary>Answer</summary>

`sendfile(socket, file, NULL, len)` copies bytes from a file fd directly
to a socket fd in the kernel, avoiding the userspace-bounce buffer
entirely. Your CPU usage drops because there is no `read`/`write`
copy and no userspace context switching per chunk; on Linux it can also
use zero-copy DMA. The trade-off is reduced flexibility (you cannot
transform bytes on the way out) and slightly more error-handling code
because `sendfile` can return short writes.

</details>

## 6. The path traversal check rejects `..` in the request path. Why is it not enough to just `strstr(path, "..")` and reject if non-NULL?

<details><summary>Answer</summary>

`..` can be URL-encoded (`%2e%2e`), Unicode-encoded
(`%c0%ae%c0%ae`), or hidden behind a redirect; a literal `strstr` misses
all of these. The right approach is to (a) URL-decode the path, (b)
canonicalize it with `realpath`, and (c) check that the canonical path
starts with the absolute path of `--files`. Reject otherwise. A defense
in depth approach also drops privileges and runs inside a `chroot` so a
miss is bounded.

</details>

## 7. Under proxy mode, the server shuttles bytes both directions. What is the right way to detect that the upstream closed first, and why is it different from the downstream-close case?

<details><summary>Answer</summary>

Use `select` / `poll` on both fds; when the upstream returns `0` from
`read` it means the upstream sent FIN. At that point you `shutdown` the
*write* side of the downstream fd (`shutdown(client, SHUT_WR)`) so the
client sees EOF, but keep reading from the client in case it still has
data to send. The two directions of a TCP connection are independent;
closing the whole socket on the first FIN truncates the response if the
client is still uploading.

</details>
