# Project 0 — Writing the Test Suite

Companion to `tests/build.sh`. Read
[`docs/testing-tutorial.md`](../docs/testing-tutorial.md) first.

Project 0 is the smallest test surface in this repo. You are not
implementing a feature — you are *debugging*. So the test plan is
inverted: most of your effort goes into *reproducing the bug* and
verifying your fix, not into a broad suite.

## What you're testing

| Feature                                  | Test type           |
| ---------------------------------------- | ------------------- |
| `src/threads/` compiles                  | build smoke         |
| Kernel boots under QEMU                  | `make check` env    |
| Buggy kernel reproduces the crash        | expected panic      |
| Fixed kernel boots without the crash     | regression          |
| Pintos `make check` reports all passes   | end-to-end          |
| `gdb` can attach and step                | manual              |

## Recipe

1. **Build smoke** (already in `tests/build.sh`). Confirms the kernel
   compiles. This is your fast feedback loop.
2. **Boot capture.** Add a script that runs QEMU non-interactively
   and saves the output:

   ```sh
   cd src/threads
   make
   timeout 30 pintos -- run alarm-multiple > /tmp/boot.log 2>&1 || true
   ```
   `|| true` because the buggy kernel exits non-zero on the panic
   you're tracking.
3. **Reproduce the bug.** Before fixing anything, write a test that
   asserts the buggy output:

   ```sh
   grep -q "PANIC at" /tmp/boot.log && pass "bug reproduces"
   ```
   If you don't pin the reproduction, you won't know whether your
   fix is the *cause* or whether the test environment changed.
4. **Apply the fix.** Edit the kernel as you've worked out under
   `gdb`. Re-run step 2.
5. **Regression test.** Same script as step 2, but invert the
   assertion: the panic line must *not* appear, and a successful boot
   marker must.
6. **`make check`.** Once your fix is in, the existing Pintos test
   suite should run cleanly. The bug is in a code path the staff
   tests exercise, so `make check` is your acceptance gate.
7. **Document the fix.** Write a short note in `STUDY.md`-style: file
   touched, why the old code crashed, why the new code does not.
   Future-you will thank you when later projects regress this fix.

## Why `make check` is not in `make test`

QEMU and the i386 cross-toolchain are not guaranteed on every host
where this repo is cloned. The repo-level `make test` only confirms
the kernel *builds*. The actual debugging happens inside the course
Docker:

```sh
cd src/threads
make
env PATH=../../utils:../utils:$PATH make check
```

Document the exact command — including the `PATH` munging that puts
`pintos`, `pintos-gdb`, and `backtrace` ahead of system tools.

## A reproducible debug session

The handout wants you to use `gdb`. Your test plan should make
`pintos-gdb` reproducible:

```sh
# Terminal 1
cd src/threads
pintos --gdb -- run alarm-multiple

# Terminal 2
pintos-gdb kernel.o
(gdb) target remote :1234
(gdb) break panic
(gdb) continue
```

Capture this in a `tests/gdb-session.txt` or a script — when you come
back to the bug after a week, you don't want to re-derive the steps.

## Try it yourself

1. The build smoke test only confirms `src/threads/` compiles. Add a
   build check for `src/devices/` and `src/lib/kernel/` too. Why are
   these reasonable additions for a *warm-up* project even though no
   later project will modify them?
2. Pintos prints the faulting `eip` on panic. Write a script that
   extracts the address, runs `addr2line` against `kernel.o`, and
   prints the source location. (Hint: `addr2line -e kernel.o`.) Make
   it a `make where` target. Why does this belong in the repo and not
   in your shell history?
3. The buggy kernel panics during a specific test. Build a *minimal*
   reproducer that triggers the same panic without running the full
   suite. What did you remove, and how do you know your reproducer
   exercises the same code path?
4. Re-run `make check` in a separate terminal while the GDB session is
   live. What happens? What does this tell you about how Pintos tests
   serialize on the build directory?
5. The `.ck` Perl scripts validate output structurally. Read one of
   them, then deliberately reorder two lines in your kernel output.
   Does the test still pass? What does that tell you about which
   output ordering matters?

## Common pitfalls

- **i386 toolchain missing.** Error looks like
  `cc: error: '-m32': unknown argument`. You need `i386-elf-gcc`,
  not host `gcc`.
- **QEMU not installed.** `make check` prints `pintos: cannot find
  qemu-system-i386`. Install `qemu-system-x86`.
- **Output captured from QEMU is buffered.** A panic that should
  appear may be cut off by a `SIGKILL` from `timeout`. Always pipe
  through `unbuffer` or set the QEMU `-monitor stdio` flag.
- **GDB connects but symbols are missing.** You ran `pintos-gdb
  build/kernel.o` from the wrong directory, or `make` was not run.
  GDB is silent about missing debug info.
- **The fix works on your machine, fails in CI.** ASLR, kernel
  initialization order, or interrupt timing differs. Pin the random
  seed (`-pintos-jitter=0`) or document the environment.
