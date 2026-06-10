# Lab Report — HW 4: Memory (`hw-memory`)

> Handout: Fall 2025, `cs162.org/static/hw/hw-memory/` (Wayback snapshot 20250916012013;
> sbrk/library pages 20251201141052). Individual assignment — no Project-1 group code.
> Run tests with `bash tests/run.sh`; full Pintos suite:
> `cd pintos/src/memory && make check` (26 tests).

| | |
|---|---|
| Author | |
| Date | |
| Repo commit | |

## 1. Environment

| Item | Value |
|---|---|
| OS / kernel | |
| gcc (multilib for i386?) / perl / qemu-system-i386 | |
| Notes | |

## 2. Task Log

### Part A — `sbrk` syscall in Pintos (`userprog/syscall.c` + wiring)

#### A.1 Heap placement and bookkeeping
*Heap start = page-aligned address after the last loadable ELF segment (decided in `load`); start + break tracked in `struct thread`.*

- Where I compute the start; fields added to `struct thread`:

#### A.2 `syscall_sbrk(increment)` semantics
*Return old break; 0 → current break; grow: PAL_USER|PAL_ZERO pages mapped via `pagedir_set_page` only when crossing page boundaries; shrink: deallocate; failure → `(void*)-1` with all state rolled back; no lazy allocation, no hard limit, no `brk`.*

- Page-boundary math (edge cases at exact boundaries):
- Failure rollback path (what gets undone, in what order):
- Wiring: `lib/syscall-nr.h`, `lib/user/syscall.c`, handler dispatch:

#### A.3 Evidence (official tests)
`sbrk-{page,small,none,multi,zero,rv,large,mebi,fail-1,fail-2,dealloc,many,counter,oom-1,oom-2}`,
then `malloc-*`/`realloc-*` (the provided Pintos malloc starts working once sbrk does).
Framework: `full/30-pintos-single-test`, `full/31-pintos-make-check`.

### Part B — standalone allocator (`mm_alloc/mm_alloc.c`)
*First fit; block split; ZERO-FILL returned memory (graded); malloc(0)→NULL; free(NULL) no-op; coalesce adjacent free blocks; realloc edge cases ((NULL,n), (ptr,0), (NULL,0), shrink, failure leaves original intact). Real `sbrk` only — libc malloc/free/realloc banned.*

- Block header layout (prev/next/free/size; flexible array member?):
- Split + coalesce logic and the invariants I maintain:
- Zero-fill points (fresh sbrk memory vs reused blocks):
- Evidence: `full/20-mm-test-runs`, `full/21-mm-behavior-driver`
  (extend `tests/fixtures/mm_behavior.c` as you go)

## 3. Test Results

| Case | Stage | Status | Notes |
|---|---|---|---|
| 10-mm-alloc-starter-build | smoke | | SKIPs on pristine starter |
| 11-pintos-memory-builds | smoke | | |
| full/20-mm-test-runs | full | | |
| full/21-mm-behavior-driver | full | | |
| full/30-pintos-single-test (sbrk-zero) | full | | |
| full/31-pintos-make-check | full | | expect `All 26 tests passed.` |
| full/40..41 (your Pintos user tests) | full | | |

## 4. Debugging Log

| Symptom | Hypothesis | Fix | Test that now catches it |
|---|---|---|---|
| | | | |

## 5. Reflection

- The "no man's land" between break and page boundary — how my implementation behaves there and why that's acceptable per the handout:
- One bug the zero-fill requirement caught (or would catch):
