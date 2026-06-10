# Lab Report — Project Pregame (`proj-pregame`)

> Handout: Fall 2025, `cs162.org/static/proj/proj-pregame/` (Wayback snapshot 20251007151923).
> Individual project. Deliverables: 17 written questions on Gradescope + a
> small kernel fix making `do-nothing`, `do-not-much`, `stack-align-v` pass.
> Run tests with `bash tests/run.sh`; official: `cd src/userprog && make check`.

| | |
|---|---|
| Author | |
| Date | |
| Repo commit | |

## 1. Environment

| Item | Value |
|---|---|
| OS / kernel | |
| gcc (i386-capable) / perl / qemu (bochs for PINTOS_DEBUG) | |
| Notes | |

## 2. Find the faulting instruction (Questions 1–5)

| # | Question (abridged) | My answer |
|---|---|---|
| 1 | Crash VA + why inaccessible (cite Pintos macros) | |
| 2 | VA of the faulting instruction | |
| 3 | Function name + disassembly (i386-objdump) + crash instruction | |
| 4 | The C source of that function | |
| 5 | Per-instruction justification (x86 calling convention) + why the access happened | |

## 3. Step through the crash (Questions 1–7)
*`FORCE_SIMULATOR=--bochs PINTOS_DEBUG=1 pintos-test do-nothing` from `src/userprog`.*

| # | Question (abridged) | My answer |
|---|---|---|
| 1 | Thread name/address at process_execute; other threads' struct thread | |
| 2 | Backtrace | |
| 3 | Same at start_process | |
| 4 | `print/x if_` after load | |
| 5 | Why does `iret` switch modes? | |
| 6 | `info registers` after iret vs `if_` | |
| 7 | `btpagefault` output (after loadusersymbols) | |

## 4. Debug (Questions 1–6 + the fix)

| # | Item | My answer |
|---|---|---|
| 1 | The do-nothing fix (where in process.c, what, why it works) | |
| 2 | The do-not-much fix (argc relation) | |
| 3 | What stack-align-v should return and why (see stack-align-v.ck) | |
| 4 | Final fix + explicit calling-convention offsets | |
| 5 | `x/2xw $esp` at `int $0x30` | |
| 6 | args[0], args[1] in syscall_handler and their relation to #5 | |

## 5. Test Results

| Case | Stage | Status | Notes |
|---|---|---|---|
| 10-userprog-builds | smoke | | |
| full/20-do-nothing | full | | fails on unfixed starter |
| full/21-do-not-much | full | | |
| full/22-stack-align-v | full | | |

## 6. Debugging Log

| Symptom | Hypothesis | Fix | Test that now catches it |
|---|---|---|---|
| | | | |

## 7. Reflection

- The single most useful GDB trick from this exercise:
- What the stack-alignment requirement implies for Project Userprog's argument passing:
