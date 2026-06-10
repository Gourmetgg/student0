# HW 2: Understanding Check

Self-check questions for HW 2. Written by the maintainers of this repo,
not the CS 162 staff.

## 1. Why does `cd` have to be a shell built-in instead of an external `/usr/bin/cd` program?

<details><summary>Answer</summary>

`cd` changes the current working directory of the *calling* process. If it
were an external program, the shell would `fork`, the child would `chdir`,
and the child would exit — the shell's cwd would never change. Built-ins
run in the shell's own address space so they can mutate shell state
directly. The same logic applies to `exit` and (in bash) `export`.

</details>

## 2. Your shell forks a child to run `/bin/ls`. After the child exits, the shell does not `waitpid` for it. What is the immediate symptom and what is the long-term symptom?

<details><summary>Answer</summary>

Immediate: nothing visible — the prompt comes back and the shell appears
to work. Long-term: every finished child becomes a zombie process,
occupying a slot in the process table. After enough commands the table
fills up and `fork` starts returning `EAGAIN`. Always wait for foreground
children; for backgrounded children, `waitpid` with `WNOHANG` in the
prompt loop or install a `SIGCHLD` handler.

</details>

## 3. Why must redirection tokens like `>` and `<` be stripped from the argv that you pass to `execvp`?

<details><summary>Answer</summary>

`execvp` does not interpret `>` — it would pass the literal string `>` to
the target program as `argv[i]`. `ls > file` then becomes `ls`, `>`,
`file` from `ls`'s point of view, which `ls` reads as "list a file named
`>` and a file named `file`". The shell is responsible for opening the
file, `dup2`-ing it onto the target fd, *removing the redirection tokens
from argv*, and only then calling `execvp`.

</details>

## 4. In a pipeline `A | B | C`, why does the shell have to close the *unused* pipe ends in each child?

<details><summary>Answer</summary>

A pipe's read end stays open until every process holding a copy closes
it. If `A` keeps the read end of its own output pipe open, `B` waits for
EOF that never comes, the pipeline deadlocks. Each child must close every
fd in the pipe set except the two it actually uses (its stdin and stdout
for that stage). The parent shell must also close all pipe ends after
forking the children, for the same reason.

</details>

## 5. The shell installs `SIG_IGN` for `SIGINT`, but the foreground child should still die from Ctrl-C. How does that work?

<details><summary>Answer</summary>

The shell ignores `SIGINT` for *itself* so Ctrl-C does not kill the
prompt. Each foreground pipeline gets its own process group via
`setpgid`, and `tcsetpgrp` hands the terminal to that group. When the user
presses Ctrl-C, the kernel sends `SIGINT` to every process in the
*foreground* process group — that is the pipeline, not the shell. The
child does not inherit `SIG_IGN` because the shell resets the disposition
back to `SIG_DFL` in the child between `fork` and `execvp`.

</details>

## 6. Why does the autograder run signal tests under a pseudo-terminal (`pty`) instead of a plain pipe?

<details><summary>Answer</summary>

Job control depends on a controlling terminal. `tcsetpgrp` only works on
an fd that is a terminal; on a pipe it returns `ENOTTY`. Without a pty,
`SIGTTIN`/`SIGTTOU` never fire, Ctrl-C does not propagate to a process
group, and the test cannot tell whether your shell is doing the right
thing or whether the harness is. The course tests use `expect` / `forkpty`
to drive the shell from a real tty.

</details>

## 7. The skeleton's tokenizer treats quoted strings specially. Why is `echo "hello world"` two tokens (`echo`, `hello world`) and not three?

<details><summary>Answer</summary>

The whitespace between `hello` and `world` is *inside* the quotes, so the
tokenizer must keep them as a single argument. If you split on every
whitespace, `echo` would receive `"hello`, `world"`, which then prints the
quotes literally. The tokenizer scans character by character, toggles an
"inside quotes" flag on each `"`, and only ends the current token when it
sees an unquoted separator. Backslash escapes and single quotes are
similar but with different escape semantics.

</details>
