# Lab Report — HW 2: Shell (`hw-shell`)

> Handout: Fall 2025, `cs162.org/static/hw/hw-shell/` (Wayback snapshot 20251110134217).
> Run tests with `bash tests/run.sh` / `RUN_FULL=1 bash tests/run.sh`. The staff
> script `test.sh` also ships in the starter (`bash test.sh`).

| | |
|---|---|
| Author | |
| Date | |
| Repo commit | |

## 1. Environment

| Item | Value |
|---|---|
| OS / kernel | |
| gcc / make | |
| Terminal/pty notes | |

## 2. Task Log

### 2.1 Directory commands (`pwd`, `cd`)
- Dispatcher entries added; syscalls used (`getcwd`/`chdir`); error behavior on bad paths:
- Evidence: `full/20-pwd-builtin`, `full/21-cd-builtin`

### 2.2 Program execution (full paths)
*Constraint: fork + exec family, parent waits. The autograder rejects any submission containing the string `execvp`.*

- fork/exec/waitpid structure; argv construction from `tokenizer.h`:
- Evidence: `full/22-external-abs-path`, `full/28-survive-bad-command`, smoke `13-no-execvp-static`

### 2.3 Path resolution (own `$PATH` walk, `execv`)
- How I split PATH (`strtok_r`) and the order of candidate checks; full paths still work:
- Evidence: `full/23-path-resolution`

### 2.4 Redirection (`>` and `<` only — no `>>`, no stderr, not for built-ins)
- Token scan, `open` flags/modes, `dup2` placement, argv stripping:
- The handout's own `wc < in > out` example result on my shell:
- Evidence: `full/24-redirect-out`, `full/25-redirect-in`, `full/29-redirect-wc-example`

### 2.5 Pipes (indefinite series)
- n−1 pipes layout; exactly which fds each child and the shell close, and why:
- Evidence: `full/26-pipe-single`, `full/27-pipe-multi`

### 2.6 Signal handling (process groups, foreground terminal)
*Each program in its own process group; fg group gets the terminal; the shell survives Ctrl-C.*

- Signals ignored in the shell and restored in children; `setpgid`/`tcsetpgrp` call sites:
- Evidence: `full/40-signal-pty-int`, `full/41-signal-pty-stop`, `full/42-fg-terminal` (write these — pty recipe in the Handbook)

### 2.7 Extra credit (1.5 pts post-curve): background processes, fg/bg
- Attempted? Design notes:
- Evidence: `full/50`, `full/51`

## 3. Test Results

| Case | Stage | Status | Notes |
|---|---|---|---|
| 10-build | smoke | | |
| 11-eof-no-hang | smoke | | |
| 12-unknown-command-no-crash | smoke | | |
| 13-no-execvp-static | smoke | | |
| full/20..29 | full | | |
| full/40..42 (pty — yours to write) | full | | |
| full/50..51 (EC) | full | | |

## 4. Debugging Log

| Symptom | Hypothesis | Fix | Test that now catches it |
|---|---|---|---|
| | | | |

## 5. Reflection

- The pipe-fd bug I hit (or designed against) and how the 3-stage test relates:
- Why signal tests need a pty (one paragraph, your own words):
