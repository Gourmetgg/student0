# Lab Report — HW 0: Introduction to CS 162 (`hw-intro`)

> Handout: Fall 2025, `cs162.org/static/hw/hw-intro/` (Wayback snapshot 20251215013051).
> Run tests with `bash tests/run.sh` (smoke) / `RUN_FULL=1 bash tests/run.sh` (behavior).

| | |
|---|---|
| Author | |
| Date | |
| Repo commit | <!-- git rev-parse --short HEAD --> |

## 1. Environment

| Item | Value |
|---|---|
| OS / kernel | <!-- e.g. WSL2 Ubuntu 24.04, Linux 6.6 --> |
| gcc / make | |
| i386 wrappers available? | <!-- i386-gcc / i386-exec / i386-gdb, or native fallback --> |
| Notes | |

## 2. Task Log

### 2.1 Counting words — total count (`words/main.c`, `words/word_count.c`)
*Goal: `./words FILE...` prints `The total number of words is: N`; stdin when no args; a word = alphabetic run of length > 1, case-insensitive.*

- What I changed:
- How I tokenize / handle EOF and the `MAX_WORD_LEN` boundary:
- Error handling added (fopen/malloc):
- Evidence: `full/20-words-total-fixture`, `full/21-words-total-multifile`, `full/22-words-stdin`

### 2.2 Counting words — frequency count (`wordcount_less`, `word_count.c` list)
*Goal: `-f` prints `<count> <word>` ascending by count, alphabetical tiebreak.*

- Linked-list design (insertion, ownership of `word` strings):
- Comparator semantics and the `init_words` abstraction note from the handout:
- Evidence: `full/23-words-freq-golden`, `full/24-words-missing-file-error`

### 2.3 User limits (`limits.c`)
*Goal: print soft limits — stack size, process limit, max file descriptors (getrlimit).*

- Which `RLIMIT_*` resources I queried and why soft (not hard):
- Output on my machine vs. the handout's sample values:
- Evidence: `11-limits-prints-three-lines`, `full/25-limits-nonzero-soft-values`

### 2.4 GDB basics (`map`, `bash i386-gdb-map.sh`)
*Written answers go to Gradescope; record them here first.*

| # | Question (abridged) | My answer |
|---|---|---|
| 4 | Address of `argv` and what it stores | |
| 6 | Address of `recur` | |
| 11 | Command to print registers | |
| 18 | Return address to `main` | |
| 21 | Instructions for `return 0` | |

### 2.5 From source code to executable (10 Gradescope questions)
- Commands used (`i386-gcc -m32 -E/-S/-c`, `objdump`):
- Answers drafted: <!-- keep your 10 numbered answers here -->

## 3. Test Results

<!-- paste the summary lines from: RUN_FULL=1 bash tests/run.sh -->

| Case | Stage | Status | Notes |
|---|---|---|---|
| 10-build-limits | smoke | | |
| 11-limits-prints-three-lines | smoke | | |
| 12-map-prints-addresses | smoke | | |
| 13-words-starter-build | smoke | | |
| full/20-words-total-fixture | full | | |
| full/21-words-total-multifile | full | | |
| full/22-words-stdin | full | | |
| full/23-words-freq-golden | full | | |
| full/24-words-missing-file-error | full | | |
| full/25-limits-nonzero-soft-values | full | | |
| full/40..42 (yours to write) | full | | |

## 4. Debugging Log

| Symptom | Hypothesis | Fix | Test that now catches it |
|---|---|---|---|
| | | | |

## 5. Reflection

- What the `-Werror` starter failure taught me about reading compiler output:
- One thing about ELF/segments I did not expect:
- Time spent / what I would do differently:
