# HW 1 — Writing the Test Suite

Companion to `tests/run.sh`. Read
[`docs/testing-tutorial.md`](../docs/testing-tutorial.md) first.

## What you're testing

| Feature                                       | Test type           |
| --------------------------------------------- | ------------------- |
| `./pthread N` spawns N threads and joins      | shape check         |
| `./lwords` output == reference `./words`      | byte-exact diff     |
| `./pwords` output == reference `./words`      | byte-exact diff     |
| Multi-file `pwords` aggregates correctly      | diff vs `words`     |
| Repeated `pwords` runs are deterministic      | stress diff loop    |
| No data races under helgrind                  | race detector       |
| No leaks under valgrind                       | memcheck            |
| Joining every thread before exit              | leak detector       |

The reference `./words` binary is your *oracle*. You don't need a hand-
computed golden file; you need parity with `words`.

## Recipe

1. **Build smoke** (already in `tests/run.sh`). Confirms all four
   binaries link.
2. **Parity, single file.** `lwords a.txt` vs `words a.txt`, then
   `pwords a.txt` vs `words a.txt`. Pipe both through `sort` before
   `diff -u` — neither program is required to print in input order.
3. **Parity, multiple files.** Use the two fixtures
   `tests/fixtures/a.txt` and `b.txt`. The point of multi-file is that
   two different threads modify the same `WordCount` for shared words.
4. **Stress for races.** Loop the multi-file `pwords` test 50 times in a
   row, diffing each run against the reference. The first divergent run
   is the race.
5. **Helgrind run.** Once per session, run
   `valgrind --tool=helgrind ./pwords a.txt b.txt` and assert exit 0.
   Slow; reserve for a `make racecheck` target.
6. **Valgrind for leaks.** Every thread that allocates must free.
   `make memcheck` runs `valgrind --leak-check=full --error-exitcode=1`.
7. **No-input edge.** `./pwords` with no arguments — what should it do?
   Pin the answer in a test before you implement.

## Why parity, not golden

`words` is the spec. If you diff `lwords` against a golden you wrote by
hand, you're testing your hand-computation. Diffing against `words`
encodes "match the reference" directly — which is exactly what the
autograder checks.

The cost: when `words` is wrong, your tests pass while the autograder
fails. The course staff treat `words` as correct; trust it.

## Build the stress loop

```sh
ref="$(mktemp)"; pw="$(mktemp)"
trap 'rm -f "$ref" "$pw"' EXIT
./words "$FIX/a.txt" "$FIX/b.txt" | sort > "$ref"
for i in $(seq 1 50); do
  ./pwords "$FIX/a.txt" "$FIX/b.txt" | sort > "$pw"
  if ! diff -q "$ref" "$pw" >/dev/null; then
    echo "FAIL: pwords diverged on run $i"
    diff -u "$ref" "$pw" | head -20
    exit 1
  fi
done
echo "PASS: 50 stress runs"
```

50 runs is a starting point — bump to 1000 once the test is fast.

## Try it yourself

1. Build a fixture where every word is unique across two files. Predict
   what changes about the failure mode if your mutex is missing. (Hint:
   no shared writes means no lost-update race.) Run with the mutex
   removed — does the test still detect a problem?
2. Modify `pwords` so it intentionally forgets to `pthread_join` the
   last worker. Which of your tests catches it? If none, write one.
3. Run your `pwords` under `valgrind --tool=helgrind` with two threads.
   Read the report carefully — every "possible data race" line names two
   accesses. Can you map both back to your source?
4. Make `pwords` spawn 100 threads on 100 files (copy `a.txt` 100
   times). Does your timing change? At what thread count does
   `pthread_create` start failing on this host?
5. The Pintos list documentation gives you `list_sort`. Use it inside
   `lwords` so output order is deterministic, then *remove* the `sort`
   from your diff harness. Why does this make failure messages clearer?

## Common pitfalls

- **Tests pass once, then fail intermittently.** Classic race. Your
  stress loop is finding it.
- **`pwords` looks correct but `valgrind` reports leaks.** You forgot to
  free per-thread state in the exit path.
- **Helgrind flags races on stdio.** `printf` is not thread-safe on its
  own under some glibcs. Confine output to the main thread after join.
- **The reference `./words` is precompiled and won't run on your arch.**
  If the `*_arm.o` files are missing for your CPU, `make` builds a stub
  `words` that may behave unexpectedly. Confirm `./words file.txt`
  outputs sensibly *before* using it as an oracle.
