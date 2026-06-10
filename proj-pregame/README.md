# Project 0: Pregame

Official handout: <https://cs162.org/static/proj/proj-pregame/>

## Introduction

Project 0 is the warm-up for the four CS 162 Pintos projects. It does not ask
you to implement a new feature; instead it gives you a buggy Pintos build,
walks you through finding the faulting instruction with `gdb`, and asks you
to fix the bug. By the end you should be comfortable building the Pintos
kernel, launching it under QEMU, attaching a debugger, and stepping through
kernel code at the instruction level.

Read the linked Pintos reference sections before starting — they describe
the parts of the kernel you will touch later (User Programs, Threads,
Processes, Memory Allocation, Lists, Development).

## Getting Started

You need the CS 162 i386 toolchain (`i386-elf-gcc`, `qemu-system-i386`).
Inside the course Docker workspace these are pre-installed.

```sh
cd ~/code/personal
git pull staff main
cd proj-pregame
make             # builds pintos/src/threads
```

Layout (subset of the full Pintos tree):

| Path                | Role                                        |
| ------------------- | ------------------------------------------- |
| `src/threads/`      | Kernel boot, thread scheduler, ASM stubs.   |
| `src/lib/`          | Shared library code.                        |
| `src/devices/`      | Timer, keyboard, disk, console.             |
| `src/utils/`        | `pintos`, `pintos-gdb`, `backtrace` scripts. |
| `src/tests/`        | The official test suite (`make check`).     |

## Tasks

### Read the Pintos reference

Skim the Overview, User Programs, Threads, Processes, Memory Allocation,
Lists, and Development sections of the Pintos manual that the handout links.
You will refer back to them in every later project.

### Find the faulting instruction

Boot the buggy kernel under QEMU. Attach `pintos-gdb` and stop at the page
fault. Identify the faulting instruction in the kernel binary, work out
which C source line it came from, and explain why it crashes.

### Fix the bug

Make a minimal fix in the kernel source. Confirm the kernel now boots and
the Pintos `make check` suite in `src/tests/threads/` passes for the basic
tests.

## Testing

```sh
make test
```

`make test` is a **build** smoke test: it compiles `src/threads/` and exits 0
on success. It does **not** run `make check` because that requires QEMU
which is not present on every host. To run the actual Pintos test suite
inside the workspace:

```sh
cd src/threads
make
make check
```

Use `pintos-gdb kernel.o` for interactive debugging, and the `backtrace`
script to translate panic addresses into source lines.

## Submission

Push `proj-pregame/` to your personal repository. Project 0 is **individual
work** — both code and written answers must be your own. See the [Submission
section](https://cs162.org/static/proj/proj-pregame/) of the handout for the
current deadline.

## Self-check

Before submitting, take a stab at these. Full answers in
[`STUDY.md`](STUDY.md).

- What kernel mechanism lets `gdb` halt the running QEMU CPU without an
  in-guest debug agent?
- Why does the course use 32-bit i386 rather than x86-64 for Pintos?
- Why can't you use the system `gcc -m32` instead of the i386 cross
  toolchain?
- Why are most Pintos test verifications written as `.ck` Perl scripts
  rather than byte-exact diffs?

## References

- Official handout: <https://cs162.org/static/proj/proj-pregame/>
- Pintos reference: linked from the handout's Tasks page.
