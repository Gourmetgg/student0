# HW 5 (C) — Writing the Test Suite

Companion to `tests/run.sh`. Read
[`docs/testing-tutorial.md`](../docs/testing-tutorial.md) first.

This homework is the hardest to test because every test starts a
multi-process cluster. The discipline is: **always clean up**, **always
use timeouts**, **always isolate output directories**.

## What you're testing

| Feature                                       | Test type           |
| --------------------------------------------- | ------------------- |
| All three binaries link                       | shape check         |
| Submitting an unknown app returns an error    | exit-status check   |
| Submitting with no workers blocks then ok     | timing              |
| `wc` over a small fixture matches golden      | end-to-end + diff   |
| `grep` job matches golden                     | end-to-end + diff   |
| `vertex_degree` job matches golden            | end-to-end + diff   |
| Reduce output is partitioned by reduce id     | file presence       |
| Killing a worker mid-map triggers retry       | fault injection     |
| Killing a worker mid-reduce triggers retry    | fault injection     |
| Polling an unknown job id fails cleanly       | exit-status check   |
| Heartbeats keep the coordinator's worker list | timing              |

## Recipe

1. **Build smoke** (already in `tests/run.sh`). Confirms all three
   binaries link and `--help` returns.
2. **Wire up `rpcbind`.** SunRPC services need it running. Guard every
   integration test with `pgrep -x rpcbind` and `SKIP` if absent.
3. **Run-cluster helper.** Build once, reuse everywhere:

   ```sh
   start_cluster() {
     OUT="$(mktemp -d)"
     "$ROOT/bin/mr-coordinator" >/tmp/mr-c.log 2>&1 &
     C=$!
     "$ROOT/bin/mr-worker"      >/tmp/mr-w.log 2>&1 &
     W=$!
     trap 'kill $C $W 2>/dev/null; wait 2>/dev/null; rm -rf "$OUT"' EXIT
     sleep 1     # poor; replace with a real readiness probe
   }
   ```
   `sleep 1` is the wrong primitive — replace with a poll for "client
   can submit." A failed health probe falls back to skip.
4. **End-to-end `wc`.** Submit, poll until done with a 30 s timeout,
   `process`, diff against `tests/golden/wc.expected`.
5. **End-to-end `grep` and `vertex_degree`.** Same shape, different
   apps. Keep one golden per app.
6. **Output partitioning.** After a job finishes, `ls $OUT` should
   contain `n` reduce output files. Assert presence and non-emptiness.
7. **Failure injection.** After `submit`, before the job completes,
   send `SIGKILL` to the worker. Start a fresh worker. Assert the job
   still completes correctly.
8. **Unknown job id.** `./bin/mr-client poll -j 99999` — exit non-zero,
   no hang.

## Golden files

Generate the golden once, by hand, on the smallest fixture you can
verify:

```
# fixture: data/test-tiny.txt
hello world hello
```

Hand-compute `wc` output for it, write to `tests/golden/wc.expected`,
diff your job's output against it. Keep the fixture in `tests/` (not
in `data/`) to make the dependency obvious.

## Fault-injection pattern

```sh
"$ROOT/bin/mr-coordinator" >/tmp/c.log 2>&1 &
C=$!
"$ROOT/bin/mr-worker"      >/tmp/w1.log 2>&1 &
W1=$!
sleep 0.5
"$ROOT/bin/mr-client" submit -a wc -n 2 -o "$OUT" -w "$FIX" >/tmp/sub.log
JOB="$(grep -oE 'job [0-9]+' /tmp/sub.log | head -1 | awk '{print $2}')"
sleep 0.5
kill -9 "$W1"                       # worker dies mid-task
"$ROOT/bin/mr-worker" >/tmp/w2.log 2>&1 &
W2=$!
trap "kill $C $W2 2>/dev/null; wait 2>/dev/null" EXIT

# poll up to 30 seconds for job done
for _ in $(seq 1 30); do
  if "$ROOT/bin/mr-client" poll -j "$JOB" | grep -q 'done'; then
    break
  fi
  sleep 1
done

diff -u "$GOLDEN" <("$ROOT/bin/mr-client" process -a wc -n 2 -o "$OUT")
```

The 30-iteration poll is your timeout *and* your wait-for-ready.

## Try it yourself

1. Predict the order in which a worker requests tasks: all maps first?
   alternating? coordinator's choice? Write a test that asserts your
   prediction by logging task IDs and grepping the log.
2. Run the cluster with two workers and a job that has two maps. How
   would you write a test that proves both workers actually got work
   (not just one running both maps)?
3. Build the fault-injection test for "kill mid-reduce." What changes
   compared to the mid-map case? (Hint: reduce input has been
   materialized; map input hasn't.)
4. Add a stress test: submit 10 jobs in a row before any of them
   complete. Does your coordinator interleave them, queue them, or
   fail? Pin the behavior.
5. The handout pins a "max retries before failing the job" number.
   Write a test that kills the worker `N+1` times and asserts the job
   reports `failed`. What's a robust way to "kill exactly N times" in
   a shell test?

## Common pitfalls

- **rpcbind not running.** Every assertion will look like "connection
  refused." Add the `pgrep -x rpcbind` guard to your harness.
- **Output directories collide.** Two tests writing to `/tmp/mr-out/`
  see each other's files. Use `mktemp -d`.
- **Stale coordinator from a previous run.** Sun RPC services register
  with `rpcbind`; if the process dies without unregistering, your new
  coordinator gets `RPC: Program already registered` on startup. Run
  `rpcinfo -d <program> <version>` to clean up.
- **`make` regenerates `rpc/rpc_*.c` on every build.** If your edits
  to those files keep disappearing, you edited the generated output
  instead of `rpc/rpc.x`.
- **Polling too tightly.** A 100 ms poll burns CPU and races with
  worker scheduling. 1-second polls are fine for the small inputs
  here.
