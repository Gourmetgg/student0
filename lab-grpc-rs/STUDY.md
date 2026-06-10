# gRPC Lab: Understanding Check

Self-check questions for the gRPC lab. Written by the maintainers of this
repo, not the CS 162 staff.

## 1. SunRPC encodes wire data with XDR; gRPC uses protobuf. What advantage does protobuf give you for *schema evolution*?

<details><summary>Answer</summary>

Protobuf fields carry a numeric tag and a wire type, and the decoder
skips unknown tags. That means you can add a new field to a request,
deploy the new server, and old clients that don't know about the field
still talk to it; new clients that send the field still talk to old
servers (the field is ignored). XDR has no tags — the decoder reads
fields by position, so renaming or adding a field breaks every
out-of-date peer. The cost is a few bytes of overhead per field.

</details>

## 2. `tonic-build` is invoked from `build.rs`. Why is the generation done at compile time rather than checked into the repo?

<details><summary>Answer</summary>

The generated code depends on the protobuf compiler version, the `tonic`
version, and the `prost` version. Checking in the output means every
machine that builds the crate needs the *exact* same toolchain to verify
nothing drifted, or you ship a binary that mismatches its declared
protocol. Generating at build time guarantees the bindings always match
the resolved dependencies. The cost is that `protoc` must be installed
on every build host, which is what `cmake >= 3.20` enables in this lab.

</details>

## 3. The server binary is fixed at `127.0.0.1:10162`. Why is a hardcoded local-loopback address acceptable for the lab but wrong for production?

<details><summary>Answer</summary>

For the lab it isolates students from each other on a shared host
(loopback) and removes one config knob (the port). In production: (a)
binding to `127.0.0.1` means you cannot serve traffic from anywhere
else, (b) a hardcoded port collides with any other service that wants
the same port, and (c) services should bind to `0.0.0.0` (or `::`) with
a configurable port so the deployer chooses. The right pattern is to
take the bind address from a CLI flag or environment variable and log
it on startup.

</details>

## 4. `tonic` services are `Send + Sync`. What does that requirement imply for the data you store inside your `KvStore` struct?

<details><summary>Answer</summary>

Every field has to be `Send + Sync` itself. A `HashMap<Vec<u8>, Vec<u8>>`
behind a `Mutex` is `Send + Sync`; a bare `HashMap` is `Send` but not
`Sync`, so two requests cannot read concurrently. The conventional
pattern is `tokio::sync::Mutex<HashMap<...>>` because the guard can be
held across `.await`. If your reads outnumber writes by a lot, an
`RwLock` lets concurrent readers in.

</details>

## 5. `tonic::Status` is the error type for an RPC. What is the difference between `Status::not_found` and returning `Ok(None)` for a missing key?

<details><summary>Answer</summary>

`Status::not_found` is part of the gRPC protocol — it sets a status code
that any gRPC client can interpret without parsing the body, and tools
like grpcurl color it red. `Ok(None)` requires the client to dig into
the response message; metrics systems looking at error rates miss it
entirely. Use `Status::not_found` for "this is a logical error from your
request"; reserve `Ok(...)` for the success path. The standard mapping
mirrors HTTP: `not_found`, `invalid_argument`, `permission_denied`, etc.

</details>

## 6. The `test.rs` file calls `client::get` after `client::put`. Each call opens a new connection. Why is that wasteful and what would a real client do?

<details><summary>Answer</summary>

A gRPC connection is over HTTP/2 with TLS handshake (typically 1-2 RTTs)
and stream initialization. Opening a fresh one per call destroys the
benefit of HTTP/2 multiplexing. A real client caches a `Channel` (the
`tonic::transport::Channel`) and reuses it for every call; only the
*stub* (the per-RPC client) is cheap. For the lab, the wasteful pattern
is fine because correctness, not throughput, is the lesson.

</details>

## 7. `cargo build` regenerates protobuf stubs every time `proto/*.proto` changes. What is the failure mode if you edit a `.proto` and forget to rerun build?

<details><summary>Answer</summary>

`build.rs` has a `cargo:rerun-if-changed=proto/...` directive, so Cargo
detects the change and re-runs the build script automatically — in
practice you cannot forget. If `rerun-if-changed` were missing, your
edited proto would compile fine, the generated `.rs` would be stale, the
server would send the old wire format while the client sent the new
one, and every RPC would fail decoding mid-message. Always include the
rerun-if-changed directive when generating code in `build.rs`.

</details>
