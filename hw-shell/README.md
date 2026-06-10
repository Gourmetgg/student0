# HW 2: Shell

Official handout: <https://cs162.org/static/hw/hw-shell/>

## Introduction

In this homework you build a small Unix shell, similar to the `bash` shell on
the CS 162 VM. Your shell reads a command line, splits it into tokens,
optionally interprets built-ins, forks a child for external programs, and
manages redirection, pipes, and terminal signals. By the end you should have a
working `cd`/`pwd`/`exit`, support for `<`, `>`, `|`, and clean signal
handling for foreground children.

## Getting Started

```sh
cd ~/code/personal
git pull staff main
cd hw-shell
make
./shell
```

| File              | Role                                                |
| ----------------- | --------------------------------------------------- |
| `shell.c`         | Command loop, built-ins, exec, redirection, signals |
| `tokenizer.c/.h`  | Line → token list                                   |
| `tests/run.sh`    | Smoke tests (this file)                             |
| `test.sh`         | Original two-case smoke script                      |

## Tasks

### Directory Commands

Implement the built-ins `cd`, `pwd`, and `exit`. They must run in the shell
process itself (not a child), and `cd` must update the cwd so subsequent
`pwd` reflects the new directory.

### Program Execution

For every non-built-in command, `fork`, `execv`/`execvp` the program in the
child, and `waitpid` in the parent. Do not leak zombies.

### Path Resolution

If the command does not contain `/`, search each directory in `$PATH` in order
and invoke the first executable match. If no entry matches, print a useful
error and return to the prompt.

### Redirection

Support `<`, `>`, and `>>`. Redirection tokens must not be passed to the
spawned program. Open files with the correct flags (`O_RDONLY`, `O_WRONLY |
O_CREAT | O_TRUNC`, `O_WRONLY | O_CREAT | O_APPEND`) and dup them onto
`STDIN_FILENO` / `STDOUT_FILENO` in the child.

### Pipes

Support pipelines with one or more `|`. Each stage gets its own child; the
shell creates a pipe between each adjacent pair and closes the unused ends
before `execvp`. Wait for every stage before printing the next prompt.

### Signal Handling

Place each pipeline into its own process group with `setpgid`. The shell
itself ignores `SIGINT`, `SIGTSTP`, `SIGTTIN`, and `SIGTTOU`. When a
foreground pipeline is running, give it the terminal with `tcsetpgrp`, then
take it back when the pipeline finishes.

### Foreground and Background Processes (EC)

For extra credit, support `&` to background a pipeline plus a minimal
job-control suite (`fg`, `bg`, `jobs`).

## Testing

```sh
make test
```

The default suite confirms the shell builds and does not hang on EOF or an
unknown command. Once you implement built-ins, exec, redirection, and pipes,
flip on the behavior tests:

```sh
RUN_FULL=1 make test
```

`test.sh` remains in place for the staff-provided checks. Signal-handling
tests should be run from inside an actual terminal, not a redirected pipe —
job control depends on a real `tcsetpgrp`-capable tty.

## Submission

Push the contents of `hw-shell/` to your personal repository; the autograder
covers built-ins, execution, redirection, pipes, and the signal cases listed
on the [Signal Handling
page](https://cs162.org/static/hw/hw-shell/docs/signal-handling/task/).

## Self-check

Before submitting, take a stab at these. Full answers in
[`STUDY.md`](STUDY.md).

- Why does `cd` have to be a built-in instead of an external program?
- In a pipeline `A | B | C`, which pipe ends must each child close, and why?
- Why must redirection tokens (`>`, `<`, `|`) be removed from the argv you
  pass to `execvp`?
- The shell ignores `SIGINT` for itself, yet Ctrl-C still kills the
  foreground child. How is that possible?

## References

- Official handout: <https://cs162.org/static/hw/hw-shell/>
- Directory commands: <https://cs162.org/static/hw/hw-shell/docs/directory-commands/>
- Signal handling: <https://cs162.org/static/hw/hw-shell/docs/signal-handling/task/>
