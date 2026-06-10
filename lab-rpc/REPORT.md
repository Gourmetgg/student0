# Lab Report — RPC Lab (`lab-rpc`)

> Handout: Fall 2025, `cs162.org/static/hw/lab-rpc/` (Wayback snapshot 20251202075625).
> Worth 5% of HW Map Reduce. Editable files: `kv_store.x`, `server.c`,
> `kv_store_client.c` ONLY. Run tests with `bash tests/run.sh`
> (`full/` needs `sudo service rpcbind start`).

| | |
|---|---|
| Author | |
| Date | |
| Repo commit | |

## 1. Environment

| Item | Value |
|---|---|
| OS / kernel | |
| rpcgen / libtirpc / glib | |
| rpcbind running? | |

## 2. Task Log

### 2.1 Protocol: `ECHO` in `kv_store.x`
*EXAMPLE(int)=1 is given; procedure numbers must be unique and sequential.*

- My XDR declaration:
- Evidence: build succeeds after `make` regenerates stubs

### 2.2 Server: `echo_1_svc` in `server.c`
*Static result variable (stack values die on return); no malloc needed.*

- Implementation notes:
- Evidence: `full/21-echo-roundtrip`

### 2.3 Client: `echo()` in `kv_store_client.c`
*clnt_connect → stub call → `strdup` BEFORE `xdr_free((xdrproc_t)xdr_string, ...)` → clnt_destroy. Must actually hit the server.*

- Memory ownership walk-through (who frees what, when):
- Evidence: `full/21-echo-roundtrip`

### 2.4 KV store: `PUT` / `GET`
*PUT: struct arg with key+value as variable-length char arrays (given `typedef char buf<>`); GET: buf → buf; keys/values may contain NUL bytes; server state = GHashTable + GBytes, global, init in main; single-threaded server → no locks.*

- XDR struct definitions:
- GHashTable/GBytes usage (hash/equal funcs, ownership/destroy notify):
- My behavior for GET on a missing key (the handout leaves it open — document your contract):
- Evidence: `full/22-put-get-roundtrip`, `full/23-put-overwrite`,
  `full/40-binary-safe-keys` + `full/41-get-missing-key` (yours)

## 3. Test Results

| Case | Stage | Status | Notes |
|---|---|---|---|
| 10-build / 11-binaries-exist / 12-client-no-args | smoke | | |
| full/20-example-roundtrip | full | | passes on starter (plumbing check) |
| full/21-echo-roundtrip | full | | |
| full/22-put-get-roundtrip | full | | |
| full/23-put-overwrite | full | | |
| full/40..41 (yours to write) | full | | |

## 4. Debugging Log

| Symptom | Hypothesis | Fix | Test that now catches it |
|---|---|---|---|
| | | | |

## 5. Reflection

- What `rpcgen` generates from one `.x` line (trace one RPC end to end):
- Why the static-result convention exists and what would break without it:
