# Lab Report — HW 1: List (`hw-list`)

> Handout: Fall 2025, `cs162.org/static/hw/hw-list/` (Wayback snapshot 20251008233309).
> Run tests with `bash tests/run.sh` / `RUN_FULL=1 bash tests/run.sh`.

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
| Notes (ARM `.o` variants used?) | |

## 2. Task Log

### 2.1 pthread analysis (read-only — no code changes allowed)
*Answer on Gradescope; draft here. Run `./pthread` several times first.*

| # | Question (abridged) | My answer |
|---|---|---|
| 1 | Same output every run? Why (not)? | |
| 2 | Do threads share a stack? Evidence? | |
| 3 | Do threads share globals? Evidence? | |
| 4 | What is `void* threadid` really? | |
| 5 | With many threads, do all run before exit? Precisely why? | |

### 2.2 `lwords` — Pintos-list word count (`word_count_l.c`)
*Goal: implement the `word_count.h` API on `struct list`; `lwords` ≡ frequency mode of `words`.*

- How `word_count_t` embeds `struct list_elem` (PINTOS_LIST macro view):
- `wordcount_sort` with an arbitrary comparator — how I kept it generic:
- Evidence: `full/20-lwords-matches-words`

### 2.3 `pwords` — threaded word count (`pwords.c`, `word_count_p.c`)
*Goal: one thread per input file updating ONE shared list; fine-grained sync (a global lock around `count_words` loses points); no intermediate files.*

- Thread creation/join structure in `pwords.c`:
- What exactly my mutex protects (and what it deliberately does not):
- Why this counts as fine-grained per the handout:
- Evidence: `full/21..23`, `full/30-pwords-race-stress`

### 2.4 Gradescope performance questions
*Run both on `gutenberg/` with `time` first.*

| # | Question (abridged) | My answer |
|---|---|---|
| 1 | lwords vs pwords on Gutenberg — numbers + explanation | |
| 2 | When does each win? Can threading always win? | |

## 3. Test Results

| Case | Stage | Status | Notes |
|---|---|---|---|
| 10-build-all | smoke | | |
| 11-pthread-runs | smoke | | |
| 12-words-reference-output | smoke | | |
| full/20-lwords-matches-words | full | | |
| full/21-pwords-matches-words | full | | |
| full/22-pwords-multifile-parity | full | | |
| full/23-pwords-gutenberg-parity | full | | |
| full/30-pwords-race-stress | full | | |
| full/40..42 (yours to write) | full | | |

## 4. Debugging Log

| Symptom | Hypothesis | Fix | Test that now catches it |
|---|---|---|---|
| | | | |

## 5. Reflection

- A race I introduced (or nearly did) and how the parity/stress tests exposed it:
- Where the Pintos list API surprised me vs. a textbook linked list:
