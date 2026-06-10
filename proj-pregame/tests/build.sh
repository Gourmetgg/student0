#!/usr/bin/env bash
# Build smoke test for Project 0: Pregame.
#
# This script confirms the Pintos thread sub-build compiles. It does NOT run
# the Pintos test suite (`make check`) because that requires QEMU and the
# CS 162 i386 toolchain, which are not always present.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

cd "$ROOT/src/threads"
if make >/tmp/proj-pregame-build.log 2>&1; then
  echo "PASS: pintos/src/threads built"
  exit 0
fi
echo "FAIL: pintos/src/threads did not build"
tail -50 /tmp/proj-pregame-build.log
echo
echo "Note: this homework requires the CS 162 i386 toolchain (i386-elf-gcc,"
echo "qemu-system-i386). Run inside the course Docker workspace or VM."
exit 1
