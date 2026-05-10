CS 162 Local Validation Report
==============================

Validation date: 2026-05-10

Scope
-----

This report records what was actually tested after the WSL toolchain was
installed. Implementation experiments were performed in a disposable scratch
copy, not in this tracked repository. The tracked homework source code remains
the original code.

Scratch copy used:

```text
student0-verify-scratch-1
```

Toolchain observed in WSL:

```text
cargo 1.95.0
rustc 1.95.0
rpcgen /usr/bin/rpcgen
/usr/include/tirpc/rpc/rpc.h
qemu-system-i386 available
glib-2.0 pkg-config available
```

Commands Run
------------

Core C and allocator harness in the scratch copy:

```sh
scratch-tests/run-core-tests.sh
```

Result:

```text
PASS hw-intro words
PASS hw-list lwords/pwords
PASS hw-shell builtins/external/redirection/pipes
PASS hw-http file/directory/404 across server modes
PASS hw-memory mm_alloc
ALL CORE TESTS PASSED
```

Pintos memory suite in the scratch copy:

```sh
cd hw-memory/pintos/src/memory
env PATH=../../utils:../utils:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make check
```

Result:

```text
All 26 tests passed.
```

C MapReduce build in the scratch copy:

```sh
cd hw-map-reduce
make
```

Result:

```text
Build passed after TIRPC and glib dependencies were installed.
```

Rust HTTP tests in the scratch copy:

```sh
cd hw-http-rs
cargo test
```

Result:

```text
12 tests ran.
6 passed.
6 failed because the original Rust HTTP code still contains todo! placeholders
in MIME type handling, header termination, and stats counting.
```

Rust MapReduce tests in the scratch copy:

```sh
cd hw-map-reduce-rs
cargo test
```

Result:

```text
Compilation failed because src/tests/mod.rs contains
todo!("Pick an input file"), leaving the ignored test without an inferable type.
The coordinator also still contains job-submission and task-management TODOs.
```

What The Scratch Completion Proved
----------------------------------

The scratch implementation showed that the following homework areas can be
completed and tested in the installed WSL environment:

- HW 0 word counting.
- HW 1 list-backed and pthread-backed word counting.
- HW 2 deterministic shell behavior.
- HW 3 C HTTP server behavior across basic, fork, thread, and pool modes.
- HW 4 standalone allocator behavior.
- HW 4 Pintos `sbrk` and active memory tests.

The tests also caught real mistakes during scratch development:

- HW 1 output spacing had to match the reference binary exactly.
- HW 4 allocator returned misaligned pointers until the block header layout was
  fixed.
- HW 3 HTTP tests exposed the original accept-loop problem before the scratch
  implementation was corrected.

Remaining Validation Work
-------------------------

C MapReduce now builds, but it still needs an end-to-end cluster test after the
coordinator is implemented.

Rust HTTP now runs tests, but the original code still fails helper tests because
core helpers are unimplemented.

Rust MapReduce does not yet compile under `cargo test` because a placeholder in
the test module prevents type inference. After that placeholder is replaced,
worker registration, job submission, task assignment, completion, retry, and
end-to-end output tests are still required.

Repository State
----------------

Only Markdown documentation is kept in the tracked repository. PDFs, HTML
exports, generated build scripts, scratch test harnesses, and scratch
implementation changes are intentionally excluded.
