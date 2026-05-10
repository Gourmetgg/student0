HW Shell
========

Overview
--------

This homework implements a small Unix-style shell. The main program reads
commands, handles built-in behavior, tokenizes input, and executes external
programs.

Key files
---------

- `Makefile`: builds the `shell` executable.
- `shell.c`: shell loop, built-ins, and process execution.
- `tokenizer.c` and `tokenizer.h`: command parsing support.
- `test.sh`: current smoke-test script.

Build
-----

```sh
cd hw-shell
make
```

Local test plan
---------------

Run the included smoke tests:

```sh
bash test.sh
```

Run manual command checks:

```sh
echo "pwd" | ./shell
echo "/bin/ls" | ./shell
echo "/bin/echo hello" | ./shell
```

Test completeness review
------------------------

Current status: smoke-test only. The existing `test.sh` checks one built-in
command (`pwd`) and one external command (`/bin/ls`). That is helpful, but it is
not a complete shell test suite.

What is currently covered:

- The shell can build.
- A simple built-in command can run.
- A simple external command can run.

Important gaps:

- No tests for empty input, whitespace-only input, repeated commands, invalid
  commands, command arguments, or command exit status.
- No direct tokenizer unit tests.
- No tests for process cleanup or error messages.
- No coverage for additional shell features if the assignment expects them.

Recommended missing tests
-------------------------

- Expand `test.sh` into a table-driven script with expected stdout, stderr, and
  exit status.
- Add tokenizer tests for whitespace, arguments, and malformed input.
- Add negative tests for nonexistent commands.
- Add a repeated-command test to catch state that leaks between commands.
