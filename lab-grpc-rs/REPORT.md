# Lab Report — gRPC Lab (`lab-grpc-rs`)

> Handout: Fall 2025, `cs162.org/static/hw/lab-grpc-rs/` (Wayback snapshot 20251206133213).
> Worth 5% of HW Map Reduce (Rust). Editable files: `proto/kv_store.proto`,
> `src/server.rs`, `src/client.rs` ONLY (`src/rpc/kv_store.rs` is regenerated
> by every build). Run tests with `bash tests/run.sh`.

| | |
|---|---|
| Author | |
| Date | |
| Repo commit | |

## 1. Environment

| Item | Value |
|---|---|
| OS (local dev recommended) | |
| rustc / cargo / CMake (≥3.20) | |
| Notes | |

## 2. Task Log

### 2.1 Protocol buffers: `Echo`
*Convention: RPC `Foo` ⇒ `FooRequest`/`FooReply`; sequential field numbers. Example is given.*

- My proto additions:

### 2.2 Server: `echo` on the `KvStore` service
*After the proto edit, cargo build errors until the trait fn exists; verify with `cargo check`.*

- Implementation notes (`req.into_inner()`, Response wrapping):
- Evidence: `full/22-cli-echo-put-get`, staff `test_echo`

### 2.3 Client: `echo()` in `src/client.rs`
- Channel/connect pattern reused from `example`:
- Evidence: `./target/debug/client echo test` → `test`

### 2.4 KV store: `Put` / `Get`
*bytes ⇄ Vec<u8>; Put overwrites duplicates; Get on a missing key must return exactly `Err(Status::new(Code::NotFound, "Key does not exist."))`; state = HashMap behind `Arc<tokio::sync::RwLock<...>>` (async multi-threaded server ⇒ sync required), new field on `KvStore`, initialized in `start`.*

- Proto messages:
- Lock usage per RPC (read vs write guard):
- Evidence: staff `test_put`/`test_get` (`full/21-staff-acceptance`),
  `full/22-cli-echo-put-get`, `full/40-notfound-exact-status` (yours)

## 3. Test Results

| Case / test | Stage | Status | Notes |
|---|---|---|---|
| 10-cargo-build / 11-smoke-suite | smoke | | |
| full/20-example-roundtrip-cli | full | | passes on starter (plumbing check) |
| full/21-staff-acceptance (src/test.rs) | full | | the autograder contract |
| full/22-cli-echo-put-get | full | | |
| full/40-notfound-exact-status (yours) | full | | |

## 4. Debugging Log

| Symptom | Hypothesis | Fix | Test that now catches it |
|---|---|---|---|
| | | | |

## 5. Reflection

- Contrast with lab-rpc: what tonic/proto generate for you that rpcgen did not (and vice versa):
- Why this server needs a lock while the SunRPC one did not:
