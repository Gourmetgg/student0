# Lab Report — HW 3: HTTP (`hw-http`)

> Handout: Fall 2025, `cs162.org/static/hw/hw-http/` (Wayback snapshot 20251201183630).
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
| gcc / make / curl / ab | |
| Notes | |

## 2. Task Log

### 2.1 PART 1 — Socket (`serve_forever`: bind + listen)
*Socket creation and SO_REUSEADDR are starter-provided; backlog 1024.*

- What I bound and how I verified ("Empty reply from server" stage):
- Evidence: server cases all depend on this.

### 2.2 PARTs 2–3 — GET for files and directories (`handle_files_request`)
*Constraints: raw `read`/`write` syscalls only (fread/fwrite = zero credit); correct Content-Length; 404 for missing; index.html or generated listing + parent link; close the client socket.*

- Read/write loop and partial-IO handling:
- Directory dispatch (`stat`, `S_ISDIR`) and listing generation (`http_format_href`):
- Evidence: `full/20-get-index-200`, `21-get-subdir-file`, `22-missing-404`,
  `23-root-serves-index`, `24-dir-listing-parent-link`, `25-binary-byte-exact`;
  smoke `12-no-stdio-file-io-static`

### 2.3 PART 4 — Proxy (`handle_proxy_request`)
*Two pthreads shuttling bytes (select/fcntl banned); multiple requests per connection; close both sockets when either side closes.*

- Thread pair design and shutdown/teardown ordering:
- Evidence: `full/30-proxy-roundtrip`, `full/40-proxy-keepalive` (yours)

### 2.4 PARTs 5–7 — forkserver / threadserver / poolserver
- forkserver: child lifecycle, why the parent must NOT wait, fd hygiene:
- threadserver: detach-vs-join choice:
- poolserver: `wq_push`/`wq_pop` flow; exactly `--num-threads` concurrency:
- Evidence: `full/26..28`, `29-concurrent-clients`, `full/41-pool-exact-concurrency` (yours)

### 2.5 Performance (not graded, not submitted — but do it)
*`ab -n 500 -c 10` against all four variants.*

| Variant | Time/request (mean) | Observations as n,c grow |
|---|---|---|
| httpserver | | |
| forkserver | | |
| threadserver | | |
| poolserver (`--num-threads = ?`) | | |

## 3. Test Results

| Case | Stage | Status | Notes |
|---|---|---|---|
| 10-build-variants | smoke | | |
| 11-usage-no-args | smoke | | |
| 12-no-stdio-file-io-static | smoke | | |
| full/20..30 | full | | |
| full/40..42 (yours to write) | full | | |

## 4. Debugging Log

| Symptom | Hypothesis | Fix | Test that now catches it |
|---|---|---|---|
| | | | |

## 5. Reflection

- A partial-read/short-write scenario I handled and how I'd provoke it in a test:
- What changed in my mental model of "a server" after the pool variant:
