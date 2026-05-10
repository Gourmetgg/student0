HW 2: Shell
===========

Official reference:

- <https://cs162.org/static/hw/hw-shell/>
- <https://cs162.org/static/hw/hw-shell/docs/directory-commands/>
- <https://cs162.org/static/hw/hw-shell/docs/signal-handling/task/>

Assignment goals
----------------

This homework builds a small Unix-style shell. The official CS 162 task set
covers command tokenization, directory commands, program execution, path
resolution, redirection, pipes, and signal behavior.

The shell should behave like an interactive process manager: read commands,
execute foreground jobs, preserve shell state across commands, and stay alive
when user signals target a foreground child.

Key implementation areas
------------------------

- `shell.c`: command loop, built-ins, `fork`/`exec`, waiting, redirection,
  pipes, and signal handling.
- `tokenizer.c` and `tokenizer.h`: parsing input into command tokens.
- `test.sh`: current smoke-test script.
- `Makefile`: build rules for the `shell` binary.

Build and run
-------------

```sh
cd hw-shell
make
bash test.sh
./shell
```

Manual command examples:

```sh
printf "pwd\n" | ./shell
printf "cd /\npwd\n" | ./shell
printf "/bin/echo hello\n" | ./shell
printf "echo hello | wc -w\n" | ./shell
printf "echo saved > /tmp/hw-shell-out\n" | ./shell
```

Current test inventory
----------------------

`test.sh` currently provides smoke coverage for:

- One built-in `pwd` command.
- One external `/bin/ls` command.

That is helpful, but it is not enough for the official shell behavior.

Completeness assessment
-----------------------

Coverage is incomplete. A shell is stateful and process-heavy, so tests should
exercise sequences of commands, not only isolated one-line invocations.

Missing coverage includes:

- `cd` success and failure cases.
- `pwd` after directory changes.
- Empty input and whitespace-only input.
- External commands with arguments.
- Unknown commands and error handling.
- PATH lookup if the implementation supports it.
- Input and output redirection.
- Single and multi-stage pipes.
- Signal behavior for Ctrl-D, Ctrl-C, and Ctrl-Z.
- Tokenizer edge cases and malformed syntax.
- Child cleanup and non-hanging behavior.

Detailed missing-test prompts
-----------------------------

1. Convert `test.sh` into a small assertion harness:

   ```sh
   run_case() {
     name="$1"
     input="$2"
     expected="$3"
     actual="$(printf "%s" "$input" | ./shell)"
     if [ "$actual" != "$expected" ]; then
       printf "FAIL %s\nexpected:\n%s\nactual:\n%s\n" "$name" "$expected" "$actual"
       exit 1
     fi
   }
   ```

   Keep prompt filtering in one place if the shell prints prompts.

2. Add directory-command tests:

   ```sh
   run_case "pwd root" "cd /\npwd\n" "/"
   run_case "cd relative" "cd /tmp\npwd\n" "/tmp"
   ```

   Also add `cd /does/not/exist` and assert that the shell prints an error but
   continues to accept the next command.

3. Add external-command tests:

   ```sh
   printf "/bin/echo hello cs162\n" | ./shell
   printf "echo path lookup\n" | ./shell
   printf "definitely-not-a-command\n/bin/echo survived\n" | ./shell
   ```

   Assert that the invalid command does not terminate the shell.

4. Add redirection tests:

   ```sh
   tmp="$(mktemp)"
   printf "echo redirected > %s\n" "$tmp" | ./shell
   grep -qx "redirected" "$tmp"
   ```

   Add input-redirection coverage with `wc -w < fixture.txt`.

5. Add pipe tests:

   ```sh
   printf "echo hello | wc -w\n" | ./shell
   printf "echo alpha | tr a-z A-Z | wc -w\n" | ./shell
   ```

   Assert the final output and ensure the shell exits cleanly after pipeline
   children finish.

6. Add tokenizer unit tests:

   Create a small `tests/tokenizer_test.c` that includes `tokenizer.h` and
   checks:

   - Multiple spaces collapse correctly.
   - Redirection symbols become separate tokens.
   - Pipe symbols become separate tokens.
   - Empty strings produce no command.
   - Malformed commands return an error instead of reading invalid memory.

7. Add Ctrl-D behavior:

   Start `./shell` with no input from a here-document or closed stdin and assert
   that it exits normally rather than spinning.

8. Add Ctrl-C behavior:

   Use a script that starts the shell, sends `sleep 5`, delivers SIGINT to the
   foreground process group, and then sends `/bin/echo alive`. The test passes
   only if `sleep` stops and the shell still runs the next command.

9. Add Ctrl-Z behavior:

   Send SIGTSTP while a foreground command is running. The shell itself should
   not become stopped. Assert that a later command still executes.

Suggested `make test` target
----------------------------

Add a `test` target that rebuilds `shell`, runs the deterministic command
tests, and only runs signal tests when the host supports Unix job-control
semantics. Mark signal tests as Linux or WSL required.
