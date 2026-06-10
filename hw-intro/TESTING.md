# HW 0 — Writing the Test Suite

Companion to `tests/run.sh`. Read
[`docs/testing-tutorial.md`](../docs/testing-tutorial.md) first — every
technique below comes from there.

## What you're testing

| Feature                                | Test type        |
| -------------------------------------- | ---------------- |
| `./limits` prints stack/process/fd     | shape check      |
| `./map` prints labelled addresses      | shape check      |
| `./words -c file` total word count     | exact value      |
| `./words -f file` per-word frequency   | normalized diff  |
| stdin input when no path given         | exact value      |
| multi-file totals merge correctly      | exact value      |
| missing file fails with non-zero exit  | failure path     |
| unknown flag fails with non-zero exit  | failure path     |
| `valgrind` reports no leaks            | memcheck         |

## Recipe

Work in this order — the next test only makes sense after the previous one
passes.

1. **Build smoke** (already in `tests/run.sh`). Confirms `limits` and
   `map` build; this is your safety net while you change other tests.
2. **Tiny word-count fixture.** Create `tests/fixtures/basic.txt` (6 words,
   2 distinct). Assert `./words -c` prints `6`.
3. **Frequency fixture.** Same file. Assert `./words -f` contains
   `3\thello`. Sort both sides before diffing — the spec does not pin
   ordering across words.
4. **stdin path.** Pipe a literal string into `./words -f`. The shape
   should be the same; this catches programs that only work when `fopen`
   succeeds.
5. **Multi-file totals.** Two fixtures with overlapping words. Assert the
   merged total and each per-word count.
6. **Failure modes.** Run `./words -c does-not-exist.txt` and assert
   non-zero exit. Run with an unknown flag (`-z`) and assert non-zero
   exit. Test both — they tend to share a flag-parsing path.
7. **Punctuation policy.** A fixture with `Hello, hello! HELLO?`. The
   handout pins the tokenizer rules; encode them in this test so you
   notice if a refactor changes them.
8. **Memcheck target.** Add a `memcheck` target to the `Makefile` that
   runs `valgrind --leak-check=full --error-exitcode=1 ./words ...`.
   Don't put it in `make test` — it's slow.

## Edge cases worth catching

- **Empty file.** `./words -c /dev/null` must print `0` and exit `0`.
- **One-character word.** `printf 'a' | ./words -c` should print `1` even
  without a trailing newline.
- **Trailing whitespace.** Words separated by tabs and runs of spaces are
  not different from words separated by one space.
- **Unicode.** The spec is ASCII; bytes ≥ 0x80 should not split words but
  they also should not crash. Decide what your tokenizer does and pin it.
- **Mixed line endings.** `\r\n` from Windows fixtures should still
  tokenize correctly.

## Build the harness once

Extend the `run_case` shape from the tutorial:

```sh
# Run command with stdin, capture stdout, assert exact match.
expect_eq() {
  local name="$1" input="$2" cmd="$3" expected="$4"
  local actual; actual="$(printf '%s' "$input" | eval "$cmd")"
  if [ "$actual" = "$expected" ]; then pass "$name"
  else fail "$name (got: $actual want: $expected)"; fi
}

# Run command, assert non-zero exit.
expect_fail() {
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then fail "$name (expected failure)"
  else pass "$name"; fi
}
```

Drop both into `tests/run.sh` once, reuse everywhere.

## Try it yourself

No answers in this file. Write the tests, run them, iterate.

1. Add `tests/fixtures/empty.txt` (zero bytes). Write the two assertions
   for `-c` and `-f` you would expect. Run them — do they pass on your
   implementation?
2. Write the failure test for `-c does-not-exist.txt`. Capture stderr and
   assert it contains the substring `does-not-exist.txt`. Why is asserting
   the path in the error message better than just asserting non-zero exit?
3. Build a fixture that triggers exactly one `realloc` inside your
   implementation (you'll need to know what your growth policy is).
   Re-run under valgrind. Does the leak count change?
4. Take your current `words -f` output, pipe it through `sort -k2 -n`,
   and verify the sort lengths are stable across multiple runs. (Hint: if
   they aren't, you have a non-deterministic iteration order. Decide
   whether to fix it or document it.)
5. The handout pins a case-folding policy. Write *two* assertions: one
   that proves your tokenizer folds case, and one that proves it does
   *not* fold inside the same word ("McAfee" stays one token, not three).

## Common pitfalls

- **Comparing to expected output with `grep`.** `grep 'hello' actual`
  passes even if `actual` contains `othello`. Use `grep -wq 'hello'` or
  diff against a golden.
- **Newline at EOF.** Most golden files end in `\n`. Most program output
  ends in `\n`. Mixed endings produce a one-character diff. Match them.
- **`echo -n` is non-portable.** Use `printf '%s' "..."` everywhere.
- **Forgetting `set -euo pipefail`.** Without it, a failed `printf | cmd`
  in a pipeline silently passes because `cmd`'s exit overrides.
