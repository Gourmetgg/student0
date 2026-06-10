# CS 162 Student Repository

This repository contains the individual homework assignments, labs, and
project 0 for CS 162. Each subdirectory has a handout-style `README.md`
mirroring the layout used on <https://cs162.org>, and a `make test` target
that runs a small smoke suite.

## Assignments

| Directory              | Handout                                                   |
| ---------------------- | --------------------------------------------------------- |
| `hw-intro/`            | <https://cs162.org/static/hw/hw-intro/>                   |
| `hw-list/`             | <https://cs162.org/static/hw/hw-list/>                    |
| `hw-shell/`            | <https://cs162.org/static/hw/hw-shell/>                   |
| `hw-http/`             | <https://cs162.org/static/hw/hw-http/>                    |
| `hw-http-rs/`          | <https://cs162.org/static/hw/hw-http-rs/>                 |
| `hw-memory/`           | <https://cs162.org/static/hw/hw-memory/>                  |
| `hw-map-reduce/`       | <https://cs162.org/static/hw/hw-map-reduce/>              |
| `hw-map-reduce-rs/`    | <https://cs162.org/static/hw/hw-map-reduce-rs/>           |
| `lab-rpc/`             | <https://cs162.org/static/hw/lab-rpc/>                    |
| `lab-grpc-rs/`         | <https://cs162.org/static/hw/lab-grpc-rs/>                |
| `proj-pregame/`        | <https://cs162.org/static/proj/proj-pregame/>             |

## Running the tests

The repository-level driver runs every assignment's smoke test in order:

```sh
make test            # smoke suite — passes on the unmodified starter
make test-full       # also runs behavior tests (requires student impls)
```

Equivalently:

```sh
bash run_all_tests.sh
RUN_FULL=1 bash run_all_tests.sh
ONLY="hw-shell hw-http" bash run_all_tests.sh
```

Per-assignment:

```sh
cd <hw> && make test
```

What "smoke" means here:

- C assignments: every binary in the directory links, runs without
  crashing, and prints something plausible.
- Rust crates: `cargo test --test smoke` passes, which proves the crate
  builds and the CLI binaries respond to `--help`.
- Pintos pieces (`hw-memory`, `proj-pregame`): the kernel source compiles
  on a host with the i386 toolchain. The full Pintos `make check` suites
  are documented in each handout but are not part of `make test` because
  they require QEMU and a working autograder image.

The behavior tests (`RUN_FULL=1`) only pass once you have implemented the
required tasks. Each `tests/run.sh` describes which assertions are gated.

## Understanding checks

Each assignment ships with a short `STUDY.md` of conceptual questions plus
an inline **Self-check** section at the bottom of its `README.md`. The
questions are written by the maintainers of this repo (not by the CS 162
staff) and are intended as a pre-submission gut-check. Every answer is
behind a `<details>` toggle so you can write your own first.

```
hw-*/STUDY.md, lab-*/STUDY.md, proj-pregame/STUDY.md
```

## Learn to write the tests yourself

The `tests/run.sh` and `tests/smoke.rs` files in each assignment are
*scaffolding*. To turn them into the full test suite the testing-guide
describes, follow:

1. **[`docs/testing-tutorial.md`](docs/testing-tutorial.md)** — the
   reusable techniques: fixtures, golden files, output normalization,
   timeouts, cleanup traps, server readiness, race detection,
   memcheck, pty-driven signals, skipping cleanly, TDD order.
2. **`<hw>/TESTING.md`** — a per-assignment recipe that applies those
   techniques in order. Each file has a feature → test map, a
   step-by-step recipe, a "try it yourself" section (no answers), and
   a common-pitfalls checklist.

The tutorial gives you the vocabulary once; the per-HW files send you
to the right exercise.

## Long-form guides

Additional documentation lives in
[`docs/cs162-homework-guides`](docs/cs162-homework-guides/README.md):

- `testing-guide.md` — how to design a complete test suite per homework.
- `validation-report.md` — local validation pass on a WSL workspace.

These guides go deeper than the per-assignment `README.md` files and are a
good source of ideas when extending each `tests/run.sh`.

## Repository layout

```
student0/
├── Makefile              # repo-level `make test` / `make clean`
├── run_all_tests.sh      # driver that walks every assignment
├── hw-*, lab-*, proj-*/  # each has README.md + tests/
└── docs/                 # long-form testing and validation guides
```
