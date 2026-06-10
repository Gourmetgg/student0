# RPC Lab — Writing the Test Suite

Companion to `tests/run.sh`. Read
[`docs/testing-tutorial.md`](../docs/testing-tutorial.md) first.

## What you're testing

| Feature                              | Test type        |
| ------------------------------------ | ---------------- |
| `rpcgen` produces all four stubs     | file presence    |
| Client and server link               | smoke            |
| `./bin/client example 1` → `2`       | round-trip       |
| `./bin/client echo "hi"` → `hi`      | round-trip       |
| `put` then `get` returns the value   | sequenced calls  |
| `put` overwrites are visible         | sequenced calls  |
| `get` on missing key fails cleanly   | failure path     |
| Binary-byte keys and values work     | round-trip       |
| Server survives malformed request    | failure path     |

## Recipe

1. **Smoke** (already in `tests/run.sh`). `rpcgen` ran, both binaries
   built, `client` exits without args.
2. **rpcbind guard.** Every integration test starts with:

   ```sh
   if ! pgrep -x rpcbind >/dev/null; then
     echo "SKIP: rpcbind not running"; exit 0
   fi
   ```
   And the README spells out `sudo service rpcbind start` so a real
   workspace can run the full suite.
3. **Start-server helper.**

   ```sh
   "$ROOT/bin/server" >/tmp/srv.log 2>&1 &
   SRV=$!
   trap 'kill $SRV 2>/dev/null; wait 2>/dev/null' EXIT
   for _ in $(seq 1 30); do
     "$ROOT/bin/client" example 1 >/dev/null 2>&1 && break
     sleep 0.1
   done
   ```
   The poll for `example` doubles as the readiness probe.
4. **Round-trip example.** Already a one-liner — keep it as the
   liveness check.
5. **Round-trip echo.** `./bin/client echo hello cs162` → `hello cs162`.
6. **put/get round-trip.** `put k v` then `get k` returns `v`.
7. **Overwrite.** `put k v1; put k v2; get k` → `v2`.
8. **Binary keys.** Use `printf '\x00\xff\x7f'` for the key (your shell
   has to bypass null safely — `client` may need a `--hex` flag, or
   you can write a small C harness).
9. **Negative get.** `get does-not-exist` — non-zero exit, no hang.

## Marshalling correctness

The most common bug is "works for short strings, fails at length N." To
catch it, write a length-sweep test:

```sh
for n in 1 16 255 256 1024 4096; do
  v="$(head -c "$n" /dev/urandom | base64)"
  "$ROOT/bin/client" put "k-$n" "$v"
  out="$("$ROOT/bin/client" get "k-$n")"
  [ "$out" = "$v" ] || fail "length $n round-trip"
done
```

A bug in your XDR sizing usually shows up at the page boundary
(typically 4096 bytes).

## Try it yourself

1. Run `rpcinfo -p localhost` before and after starting your server.
   What changed? Now write a test that asserts your program number is
   registered after startup and gone after a clean shutdown.
2. The example RPC returns `arg + 1`. What does the *client* do if the
   server returns a result of unexpected type? Try to corrupt the
   server's response (edit `_svc.c` to return garbage) and see how
   `clnt_call` reports the error.
3. Build a test for the case where the server *panics* mid-call (call
   `exit(1)` inside `put_1_svc`). What error does the client see?
   What error did you predict?
4. The handout warns about returning a pointer to a stack local from
   an `_svc` function. Deliberately do it, then run your `put/get`
   test under load (a parallel `xargs` loop). What goes wrong, and
   how does your test report it?
5. `kv_store.x` defines the wire format. Add a deliberately misaligned
   change — e.g. swap two adjacent fields — and rebuild. What does the
   client report on the next call? Why is "RPC: cannot decode result"
   the canonical XDR-mismatch error?

## Common pitfalls

- **`rpcbind` not running.** Every error is misleading until you
  notice it. `pgrep -x rpcbind`.
- **Stale registration.** A crashed server leaves its program number
  registered. `rpcinfo -d <prog> <ver>` to unregister.
- **Server in foreground.** Without `&` the test hangs. Always
  background and `trap kill`.
- **`fork` for the server.** Some skeletons fork themselves on
  startup, so `$SRV` is the PID of the parent that exits, not the
  serving child. Confirm with `pgrep -f bin/server`.
- **Test runs as root in Docker.** `service rpcbind start` is fine
  there but won't work in CI without `--privileged`. Skip cleanly.
