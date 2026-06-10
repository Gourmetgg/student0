# Project 0: Understanding Check

Self-check questions for Project 0. Written by the maintainers of this
repo, not the CS 162 staff.

## 1. Pintos boots from a real i386 image under QEMU. Why does the course use 32-bit i386 instead of x86-64?

<details><summary>Answer</summary>

i386 has a much smaller surface for a teaching OS: a single privilege
transition mechanism (`int 0x80` or interrupt gates), simple segmentation
(easily disabled), simpler page tables (2 levels, 32-bit), and a small
fixed set of CPU registers. x86-64 adds two more page-table levels,
syscall/sysret mechanics, RIP-relative addressing, more registers, and a
much larger set of edge cases. The pedagogy fits in a semester only on
i386; everything you learn translates to x86-64 conceptually but in
fewer lines of code.

</details>

## 2. `pintos-gdb` attaches to a running QEMU process. What kernel mechanism allows the debugger to *halt* the running CPU?

<details><summary>Answer</summary>

QEMU's `gdbstub` — a small TCP server inside QEMU that implements the
GDB remote-serial protocol. When `gdb` says "stop", the gdbstub asks
QEMU to suspend the virtual CPU; QEMU pauses the instruction loop and
returns control to the debugger. There is no in-guest debug agent —
this works for any binary QEMU runs, even before the kernel has set up
any of its own breakpoint infrastructure.

</details>

## 3. The buggy kernel page-faults early in boot. What does "find the faulting instruction" mean — how do you go from the panic to the C source line?

<details><summary>Answer</summary>

The kernel panic prints the faulting `EIP`. Run
`objdump -d build/kernel.o | grep -B2 <addr>` (or use `addr2line` if the
binary has debug info) to find the assembly. Then look at the surrounding
function name, find that name in `pintos/src/`, and read the C. With
`-g` enabled, `gdb`'s `list *0xc0010a23` does the lookup directly.
The point of the exercise is to be comfortable doing this lookup
without help, because every later project will produce a page fault.

</details>

## 4. `i386-elf-gcc` is a *cross-compiler*. Why can't you use the system `gcc` even if the host is x86_64 Linux?

<details><summary>Answer</summary>

Pintos binaries link against no host library; they boot bare metal on a
32-bit target with a custom linker script. The system `gcc` on Ubuntu
defaults to x86-64, links in glibc startup code, and assumes a hosted
environment (`crt0`, `_start`, dynamic linker). Even with `-m32`, the
system toolchain wants to find 32-bit libc headers and a 32-bit
crtbegin.o. The cross toolchain has no host library expectations and
produces a freestanding 32-bit ELF that the boot loader can load.

</details>

## 5. The Pintos `thread_create` is described as "you should not need to modify this function." Why do the projects emphasize *which* files are stable and which are yours?

<details><summary>Answer</summary>

A stable surface lets the autograder swap in the staff reference
implementation for any file you have not been asked to modify, isolating
your bugs from staff bugs. If you change `thread.c` to "fix" a problem,
the grader runs your file against the staff harness and your "fix" may
violate an invariant the harness depends on. Treat the file-modification
list in the spec as a contract.

</details>

## 6. The `make check` target runs each test under QEMU and compares output to an expected file. Why is exact-text comparison fragile, and what does Pintos do about it?

<details><summary>Answer</summary>

Address-space layout, scheduling order, and timer interrupts make output
non-deterministic in places. Pintos has a `tests/<suite>/Make.tests`
infrastructure: each `.ck` file is a Perl script that validates the
*structure* of the output (e.g. "I see these three lines in some order")
rather than a byte-exact diff. Read a `.ck` to understand what the
grader actually checks before you spend hours chasing a literal-text
mismatch.

</details>

## 7. Project 0 is "individual work" but later projects are group projects. Why does the course explicitly call this out for the warm-up?

<details><summary>Answer</summary>

The course wants every student to develop the build-and-debug muscle
memory before the group dynamics kick in. If pregame were a team
exercise, half the team would learn to debug Pintos and the other half
would never touch `gdb` — which becomes a productivity gap that haunts
the rest of the semester. Individual pregame guarantees that everyone on
every team can independently boot and debug the kernel, so the team can
divide later work along *feature* lines rather than *who knows how to
debug*.

</details>
