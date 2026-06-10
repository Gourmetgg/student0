# Testing Tutorial

A reference for the techniques used across every assignment in this
repository. Read this once, then keep it open while you write tests in each
`hw-*/TESTING.md`. Examples are concrete, but they are tools — your job is
to compose them per assignment.

The per-assignment `TESTING.md` files contain *exercises*, not solutions.
The point is that you write the assertions yourself.

## 1. What a test is for

A test answers exactly one question: **"Does this specific piece of behavior
work?"** If a single test can fail for many reasons, you cannot tell which
behavior broke. Two consequences:

- **One assertion, one fact.** Prefer many small tests over one large one.
- **The fixture is part of the question.** Choose inputs short enough that
  you can predict the output by hand.

If you cannot predict the expected output without running the program, you
are not testing — you are observing.

## 2. Anatomy of a test

Every test has four phases, in this order:

1. **Arrange** — create a fixture, allocate a temp dir, start a server.
2. **Act** — run the code under test.
3. **Assert** — compare actual to expected.
4. **Cleanup** — kill processes, delete temp files. Use `trap` in bash and
   `Drop` / `defer`-style helpers in Rust.

Cleanup must run even when the assert fails. In bash:

```sh
set -euo pipefail
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"; kill "$srv" 2>/dev/null; wait 2>/dev/null' EXIT
```

Forgetting cleanup leaks state between tests; the second run mysteriously
fails because the first run left a port bound, a file on disk, or a
zombie process.

## 3. Fixtures: small, predictable, intentional

A fixture is the input you feed the code. Three rules:

- **Smallest input that exercises the rule.** "Hello world" is enough to
  test that two-word counting works. Use the larger Gutenberg files only for
  stress.
- **Hand-compute the expected output.** Write it as a comment next to the
  fixture. If you cannot compute it, you do not understand the spec.
- **One fixture per behavior.** Don't pack edge cases into one file — when
  it fails you can't tell which edge case broke.

```sh
# tests/fixtures/basic.txt: 6 words, 'hello' appears 3 times.
printf 'hello hello world\nsystems world hello\n' > tests/fixtures/basic.txt
```

## 4. Golden files

A *golden file* holds the expected output for a fixture. The test runs the
program, captures stdout, and `diff -u`'s against the golden file.

```sh
./words -f tests/fixtures/basic.txt > /tmp/actual
diff -u tests/golden/basic.freq /tmp/actual
```

Golden files are checked into the repo. When the expected output legitimately
changes (you added a new column, the spec changed), update the golden file
*deliberately* — never with a blanket `cp actual golden`.

### When the output is non-deterministic

If the spec does not pin an order (e.g., word frequency printed in any
order), normalize both sides before comparing:

```sh
./words -f fixture.txt | sort > /tmp/actual.sorted
sort tests/golden/basic.freq > /tmp/expected.sorted
diff -u /tmp/expected.sorted /tmp/actual.sorted
```

If the spec *does* pin an order (e.g., sorted by frequency descending), do
not sort — assert the order directly.

Other things to strip: timestamps, PIDs, random ports, absolute paths.
`sed` is the workhorse:

```sh
./server 2>&1 | sed 's/pid=[0-9]\+/pid=NNN/g; s/port=[0-9]\+/port=NNN/g'
```

## 5. Failure tests are not optional

Every feature has at least one *positive* test (happy path) and one
*negative* test (failure path). Missing-file, bad-flag, malformed input,
permission-denied, port-already-bound. The negative path is where security
bugs and panics hide.

```sh
# Positive
./words -c tests/fixtures/basic.txt | grep -q '6'

# Negative
if ./words -c tests/fixtures/does-not-exist.txt; then
  echo "FAIL: missing file should error"
  exit 1
fi
```

The shape `if cmd; then fail; fi` is the standard way to assert "this should
have failed."

## 6. Timeouts and cleanup traps

Server tests, shell tests, and MapReduce tests can hang. Every command that
might block must run under `timeout`:

```sh
timeout 5 ./shell <fixture.in
timeout 30 ./mr-client submit ...
```

Pair it with an `EXIT` trap that kills children. If you spawn a server,
keep its PID; the trap kills it whether the test passes or fails.

```sh
./server --port "$PORT" >/tmp/srv.log 2>&1 &
SRV=$!
trap 'kill "$SRV" 2>/dev/null; wait 2>/dev/null' EXIT
```

## 7. Servers: ephemeral ports + wait-for-ready

Two patterns that go together.

**Ephemeral ports.** Hard-coded port 8000 collides with other tests, your
browser, and the previous run that did not clean up. Pick a port at the top
of each test:

```sh
PORT=$(( (RANDOM % 1000) + 18000 ))
```

The Rust standard library can do better: bind to `127.0.0.1:0` and ask the
OS for the actual port back.

**Wait for ready.** A server takes some milliseconds to bind. A `sleep 1`
"works" most of the time and flakes the rest. Poll instead:

```sh
for _ in $(seq 1 50); do
  if curl -s --max-time 1 "http://127.0.0.1:$PORT/" >/dev/null 2>&1; then
    break
  fi
  sleep 0.1
done
```

Five seconds of total budget, polled at 100 ms — robust against a slow
CI host without making fast hosts wait.

## 8. Concurrency: detect what looks correct

Concurrent code can produce the right answer 1000 times and the wrong one
on the 1001st run. Three tools:

- **Stress loops.** Run the same test 50–100 times under `for i in
  $(seq 1 50); do ... done`. A single pass means nothing for a race; a
  hundred passes raises confidence quickly.
- **Helgrind / DRD.** `valgrind --tool=helgrind ./pwords ...` flags
  lock-ordering bugs and missing locks even when output looks right. Slow,
  so reserve for the dedicated stress test.
- **ThreadSanitizer.** Compile with `-fsanitize=thread` (gcc/clang) for
  C, or `RUSTFLAGS="-Zsanitizer=thread"` (nightly Rust) for Rust. Faster
  than helgrind, fewer false positives.

If you cannot reproduce a flake under stress + helgrind, the bug is probably
not a race; look at startup ordering or resource cleanup.

## 9. Memory: valgrind + ASan

`valgrind --leak-check=full --error-exitcode=1 ./prog ...` catches leaks
and use-after-free in C. AddressSanitizer (`-fsanitize=address`) catches
more (heap and stack overflows), runs ~2× faster, and integrates with
`make` via `CFLAGS`. Rust has `cargo +nightly miri test` for UB detection
on `unsafe`-light crates.

For *every* C assignment in this repo, the rule is: an automated run under
valgrind or ASan must exit 0. Add it as a separate `make memcheck` target
so it doesn't slow the default suite.

## 10. Signals require a pty

Job control (`Ctrl-C`, `Ctrl-Z`, `fg`, `bg`) depends on the calling fd
being a terminal. `printf | ./shell` is a pipe, not a terminal —
`tcsetpgrp` returns `ENOTTY`, signals don't deliver to the foreground
group, and your test cannot tell whether the shell or the harness is wrong.

The fix is a pty harness. `expect`, `python -c "import pty; ..."`, or
`script` from `util-linux` all work:

```sh
script -qfc './shell' /dev/null < signal-input.in
```

Use a pty only for signal tests. Built-ins, exec, redirection, and pipes
test fine through a regular pipe and are much faster.

## 11. Skipping is honest; lying is not

A test that "passes" on the unmodified starter when the starter cannot
possibly satisfy it is *worse than no test*. It teaches you that the
suite is green when it isn't.

Three honest options when a test can't run yet:

- **Gate behind an env var.** `[ "${RUN_FULL:-0}" = "1" ] || exit 0` lets
  default `make test` pass while the gated assertion lives in the same
  file ready for later.
- **Print `SKIP:` and exit 0.** Honest, visible in test output,
  doesn't claim success.
- **`#[ignore]` (Rust) / `pytest.mark.skip`.** Reports the skip count in
  the summary so you can see how much is hidden.

Pick one convention per repository and use it.

## 12. Reading a failed test

When a test fails:

1. **Read the diff first.** `diff -u expected actual` tells you what
   changed in one line.
2. **Narrow the fixture.** If a 200-line input fails, can you reproduce
   on 5 lines? On 1?
3. **Stress for races.** If the diff is non-deterministic across runs,
   you have a concurrency bug.
4. **Bisect.** `git bisect run make test` finds the commit that broke
   the test if it used to pass.

Never "fix" the test by widening the expected output. That hides the bug;
update the golden only after you understand *why* the output changed.

## 13. TDD order: red, green, refactor

The discipline:

1. **Red** — write a failing test that pins the next behavior you want.
2. **Green** — write the minimal code that makes the test pass. No
   features beyond what's needed.
3. **Refactor** — clean up, knowing the test will catch regressions.

For coursework, this maps to: pick the next task from the handout, write
its test first, then implement. You will be tempted to skip step 1 and
"just code it up." Resist: a test you write *after* the code tests what
the code does, not what the spec demanded.

## 14. Smells (when you read your own tests)

- Test name doesn't describe a behavior. ("test1" is a smell.)
- One test makes more than 3–4 assertions.
- The expected output is computed by running the program.
- No cleanup, no timeout, no trap.
- The test only passes when you run it after other tests.
- A flake — passes 9 runs, fails 1. *Always investigate.*
- The fix is to change the test, not the code.

## 15. Per-language quick reference

### C with bash harness

```sh
#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
FAIL=0
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; FAIL=1; }

# arrange / act / assert ...

[ "$FAIL" -eq 0 ]
```

### Rust

```rust
#[test]
fn name_describes_behavior() {
    // arrange
    // act
    // assert
    assert_eq!(actual, expected, "context for diagnosis");
}

#[tokio::test]
async fn async_version() { /* ... */ }
```

### Pintos

Pintos tests are Perl `.ck` checks against captured output. Read
`tests/<suite>/<name>.ck` to learn the expected shape before debugging a
literal-text mismatch.

---

Next: open the `TESTING.md` in the assignment you want to attack. It
contains a recipe (build the suite in this order) and exercises (try this
yourself; no answers).
