# Lab Report — HW 3: Rust HTTP Server (`hw-http-rs`)

> Handout: Fall 2025, `cs162.org/static/hw/hw-http-rs/` (Wayback snapshot 20251031031755).
> Run tests with `bash tests/run.sh` / `RUN_FULL=1 bash tests/run.sh`
> (orchestrates `cargo test` targets; behavior tests live in `tests/behavior.rs`).

| | |
|---|---|
| Author | |
| Date | |
| Repo commit | |

## 1. Environment

| Item | Value |
|---|---|
| OS (local dev recommended by the handout) | |
| rustc / cargo (`rust-toolchain.toml` honored?) | |
| Notes | |

## 2. Task Log

### 2.1 Part 1 — HTTP helpers (`http::end_headers`, `http::get_mime_type`)
*`parse_request`, `start_response`, `send_header`, `format_href/index` are given.*

- Extension → MIME mapping choices and the default:
- Evidence: staff unit tests (`full/20-unit-tests` — the http ones), `behavior::mime_type_from_extension`

### 2.2 Part 2 — Listen (`server::listen`)
*Bind 0.0.0.0:port with tokio TcpListener; accept loop; `tokio::spawn` per connection. Sanity check: curl makes the starter panic with "TODO: Part 3".*

- Accept-loop structure; error handling on accept:
- Evidence: `behavior::ten_concurrent_clients`

### 2.3 Part 3 — GET handling (`server::handle_socket`)
*Files: Content-Type + Content-Length; ≤1024 bytes of file in memory at a time; prepend "." to the path; tokio::fs only. Directories: index.html → 200; else listing + parent link (metadata, not File::open errors). 404 for missing; never panic — log::warn! and continue.*

- Streaming read/write loop (buffer size, AsyncReadExt/AsyncWriteExt usage):
- Path handling (`Path`/`PathBuf` vs raw strings):
- Evidence: `behavior::serve_index_200_with_length`, `missing_file_404`,
  `root_serves_index_html`, `dir_listing_has_children_and_parent_link`,
  `todo_streaming_uses_bounded_memory` (yours), `todo_no_panic_on_malformed_input` (yours)

### 2.4 Part 4 — Statistics (`stats.rs` + wiring)
*`Stats::incr` via HashMap::entry; then thread safety with `Arc<tokio::sync::RwLock<Stats>>`; serve counts at `/stats` (overrides files there).*

- Where incr is called for each status code path:
- Lock granularity (read vs write acquisitions):
- Evidence: staff tests `incr_items`, `incr_items_four`, `items_sorted`;
  `behavior::stats_url_reports_counts`

## 3. Test Results

| Case / test | Stage | Status | Notes |
|---|---|---|---|
| 10-cargo-build | smoke | | |
| 11-smoke-suite | smoke | | |
| full/20-unit-tests (12 staff unit tests) | full | | starter: 6 fail by design |
| full/21-behavior-suite | full | | |
| behavior::todo_* (yours to write) | full | | |

## 4. Debugging Log

| Symptom | Hypothesis | Fix | Test that now catches it |
|---|---|---|---|
| | | | |

## 5. Reflection

- One ownership/borrow fight I had with the async code and the resolution:
- Why the handout forbids `std::fs` inside the async handler:
