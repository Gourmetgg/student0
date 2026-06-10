# HW 2 — Writing the Test Suite

Companion to `tests/run.sh`. Read
[`docs/testing-tutorial.md`](../docs/testing-tutorial.md) first.

## What you're testing

| Feature                                    | Test type       |
| ------------------------------------------ | --------------- |
| Built-in `pwd` echoes cwd                  | exact equality  |
| Built-in `cd` changes cwd of the shell     | sequenced cmds  |
| Built-in `exit` ends the shell             | exit status     |
| External `/bin/echo arg` round-trips       | exact equality  |
| `$PATH` lookup for `echo` (no slash)       | exact equality  |
| `>` redirection writes a file              | filesystem      |
| `<` redirection reads a file               | exact equality  |
| `|` pipes data between processes           | exact equality  |
| Multi-stage pipelines (`a | b | c`)        | exact equality  |
| Bad command does not kill shell            | sequenced cmds  |
| Ctrl-D / EOF exits cleanly                 | exit status     |
| Ctrl-C kills foreground only (pty only)    | pty harness     |
| Ctrl-Z stops foreground only (pty only)    | pty harness     |
| Tokenizer edge cases (quotes, spaces)      | unit            |

## Recipe

1. **Build smoke + non-hang on bad input.** Already in `tests/run.sh`.
2. **Sequenced commands harness.** Most tests feed multiple lines to one
   shell instance and check the cumulative output. Build the helper
   once:

   ```sh
   run_lines() {
     local name="$1"; local input="$2"; local expected="$3"
     local actual; actual="$(printf '%s' "$input" | timeout 3 ./shell)"
     [ "$actual" = "$expected" ] && pass "$name" \
       || fail "$name (got: $actual want: $expected)"
   }
   ```
3. **Built-ins.** `pwd`, then `cd /tmp; pwd`, then `cd /` and
   `pwd`. The `cd` test is what catches "cd is in a child process" bugs.
4. **External commands.** `/bin/echo hello`, then `echo hello` (PATH
   lookup), then `definitely-not-a-cmd; /bin/echo alive` (assert
   `alive` in output).
5. **Redirection.** `> file`, then `< file`, then `>>` for append. Use
   `mktemp` and clean up under `trap`.
6. **Pipes.** `/bin/echo a b c | /usr/bin/wc -w` → `3`. Three-stage:
   `echo a | tr a-z A-Z | wc -c`. Check both byte count and the
   newline policy.
7. **Tokenizer unit tests.** `tokenizer.c` has a public API — write a
   tiny C test in `tests/tokenizer_test.c` that links against it.
   Assert quoted strings, redirection symbols, and pipes tokenize as
   distinct elements.
8. **Signal tests under pty.** This is the only block that needs
   special infrastructure. See the next section.

## Pty-driven signal tests

Job control needs a controlling terminal. Use `script`:

```sh
script -qfc './shell' /dev/null <<'EOF'
sleep 5 &
fg
EOF
```

For programmatic delivery of SIGINT to the foreground group, use
Python's `pty` module or `expect`:

```sh
python3 - <<'EOF'
import os, pty, signal, time
pid, fd = pty.fork()
if pid == 0:
    os.execvp('./shell', ['./shell'])
os.write(fd, b'sleep 30\n')
time.sleep(0.3)
os.killpg(pid, signal.SIGINT)
os.write(fd, b'/bin/echo alive\n')
# read fd, assert 'alive' present, assert sleep is gone
EOF
```

Gate signal tests behind `RUN_PTY=1` — they're slow and don't run in CI
that lacks `script` or Python.

## Try it yourself

1. The `cd` test feeds `cd /tmp; pwd` and expects `/tmp`. Write the
   *failure* test: `cd /does/not/exist; /bin/echo survived`. What
   should be in the output? Implement the assertion.
2. Build a pipeline that breaks if a child does not close unused pipe
   ends — for example, `cat | head -1` followed by a large stream.
   Predict the failure mode of a buggy shell (hint: head exits, parent
   keeps writing). Now write a test that catches it.
3. Your shell should propagate the child's exit status to `$?`. Write
   a test that runs `false` and asserts the next prompt knows the
   command exited non-zero. (You may need to add `$?` support first.)
4. Run `valgrind ./shell <basic.in 2>&1 | head -20`. Are the
   complaints in your code or in `tokenizer.c`? Decide what counts as
   "ours to fix."
5. The handout mentions extra-credit foreground/background `&`. Sketch
   the test that demonstrates `sleep 5 &` returns the prompt before 5
   seconds. What's the assertion you'd write to prove "before 5
   seconds" without flaking on slow hosts?

## Common pitfalls

- **`echo` is a shell built-in in bash but an external in your test
  shell.** `printf "echo hi\n" | ./shell` may invoke `/usr/bin/echo`,
  which behaves slightly differently from `bash` builtin. Use the full
  path in tests to be explicit.
- **Children inherit your shell's ignored signals.** Reset `SIGINT`
  back to `SIG_DFL` in the child between `fork` and `exec`, or Ctrl-C
  in the foreground child won't kill it.
- **Whitespace in `expected`.** Your prompt may print before, after, or
  between commands. Decide if your tests strip prompts (recommended) or
  expect them.
- **Race between `kill` and `read`.** When delivering SIGINT and then
  reading from the pty, your test may grab the bytes before the child
  has died. Add a short `select` / `time.sleep(0.1)` before asserting
  the post-signal state.
