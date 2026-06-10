# Lab Report — HW 5: Map Reduce, Rust (`hw-map-reduce-rs`)

> Handout: Fall 2025, `cs162.org/static/hw/hw-map-reduce-rs/` (Wayback snapshot
> 20251110141540; task pages verified via Sp25 captures + Fall25 nav).
> Components: gRPC lab (5%) → checkpoint (5%, through Tasks) → final.
> Run tests with `bash tests/run.sh` / `RUN_FULL=1 bash tests/run.sh`.

| | |
|---|---|
| Author | |
| Date | |
| Repo commit | |

## 1. Environment

| Item | Value |
|---|---|
| OS (local dev strongly recommended) | |
| rustc / cargo / CMake (≥3.20) | |
| Notes | |

## 2. Task Log
*All protocol buffers are given; the worker and client are given. You write the
coordinator (`src/coordinator/mod.rs`) behind ONE `Arc<tokio::sync::Mutex<CoordinatorState>>`
(the handout explicitly discourages fine-grained locking).*

### 2.1 Worker registration (`Register`) + heartbeats (`Heartbeat`)
*Unique small nonnegative IDs (they derive worker ports); record last-heartbeat time per worker.*

- ID counter + worker table design:
- Evidence: log-based check (handout suggests log::info!), staff test_wc setup

### 2.2 Job submission (`SubmitJob`) + queueing + `PollJob`
*Unique job IDs; FCFS but work-conserving; VecDeque/HashMap; PollJob errors field must carry worker error messages verbatim.*

- CoordinatorState fields and why each exists:
- Evidence: `full/20-staff-test-wc`, `behavior::e2e_wc_job_completes`

### 2.3 Task assignment (`GetTask`) + completion (`FinishTask`) — checkpoint
*Maps before reduces per job; reply includes map_task_assignments (reduce workers pull map output from worker MEMORY); wait flag; checkpoint = passing through `mr-no-duplicates`.*

- Selection logic ("each worker gets the first available task"):
- Evidence: `behavior::todo_fcfs_queue_order` (yours)

### 2.4 Fault tolerance (`FailTask` + heartbeat timeouts) — final
*Worker dead = no heartbeat for TASK_TIMEOUT_SECS (slow ≠ dead). Crashed
worker ⇒ its incomplete reduces AND its **completed maps** become available
again (map output lived in its memory) with priority over later jobs;
completed reduces stay done (on disk). FailTask retry=true → reassign;
retry=false → job fails immediately, error preserved to the client.*

- Death detection sweep; how completed-map re-execution is triggered:
- Error propagation path into PollJobReply.errors:
- Evidence: `behavior::todo_crashed_worker_maps_rerun`,
  `behavior::todo_error_message_preserved` (yours)

## 3. Test Results

| Case / test | Stage | Status | Notes |
|---|---|---|---|
| 10-cargo-build / 11-smoke-suite | smoke | | |
| full/20-staff-test-wc (`cargo test test_wc -- --ignored`) | full | | fill the `todo!("Pick an input file")` first |
| full/21-behavior-suite (e2e) | full | | |
| behavior::todo_* (yours to write) | full | | |

## 4. Debugging Log

| Symptom | Hypothesis | Fix | Test that now catches it |
|---|---|---|---|
| | | | |

## 5. Reflection

- Single-mutex design: where contention could appear and why it's acceptable here:
- The most subtle difference from the C variant (in-memory map outputs!) and how it changed your fault-tolerance logic:
