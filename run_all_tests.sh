#!/usr/bin/env bash
# Repository-wide test driver.
#
# Runs the smoke test for every assignment that has one. Prints a PASS/FAIL/SKIP
# line per assignment and returns non-zero if any assignment fails.
#
# Override which assignments run:
#   ONLY="hw-shell hw-http" bash run_all_tests.sh
# Enable full behavior tests (requires student implementations):
#   RUN_FULL=1 bash run_all_tests.sh

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"

DIRS=(
  hw-intro
  hw-list
  hw-shell
  hw-http
  hw-http-rs
  hw-memory/mm_alloc
  hw-map-reduce
  hw-map-reduce-rs
  lab-rpc
  lab-grpc-rs
  proj-pregame
)

if [ -n "${ONLY:-}" ]; then
  read -r -a DIRS <<<"$ONLY"
fi

PASSED=()
FAILED=()
SKIPPED=()

for d in "${DIRS[@]}"; do
  if [ ! -d "$d" ]; then
    echo "[SKIP] $d (directory missing)"
    SKIPPED+=("$d")
    continue
  fi
  echo
  echo "=========================================="
  echo "[RUN] $d"
  echo "=========================================="
  if make -C "$d" test; then
    echo "[PASS] $d"
    PASSED+=("$d")
  else
    rc=$?
    echo "[FAIL] $d (exit $rc)"
    FAILED+=("$d")
  fi
done

echo
echo "=========================================="
echo "Summary"
echo "=========================================="
echo "passed:  ${#PASSED[@]}  ${PASSED[*]:-}"
echo "failed:  ${#FAILED[@]}  ${FAILED[*]:-}"
echo "skipped: ${#SKIPPED[@]}  ${SKIPPED[*]:-}"

[ "${#FAILED[@]}" -eq 0 ]
