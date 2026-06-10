#!/usr/bin/env bash
# run_all_tests.sh — drive every assignment's test suite in order.
#
#   bash run_all_tests.sh                 # smoke suite (passes on clean starter)
#   RUN_FULL=1 bash run_all_tests.sh      # also run gated behavior tests
#   ONLY="hw-shell hw-http" bash run_all_tests.sh
#
# Each assignment is run via `bash <hw>/tests/run.sh` (see tests/runner.sh for
# the case protocol). The summary table reports per-assignment totals; the
# script exits non-zero iff any assignment had a FAILing case.

set -u -o pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ALL_DIRS="hw-intro hw-list hw-shell hw-http hw-http-rs hw-memory \
          hw-map-reduce hw-map-reduce-rs lab-rpc lab-grpc-rs proj-pregame"
DIRS="${ONLY:-$ALL_DIRS}"

declare -A RESULT TOTALS
overall=0

for d in $DIRS; do
  if [ ! -f "$ROOT/$d/tests/run.sh" ]; then
    RESULT[$d]="MISSING"; TOTALS[$d]="-"
    overall=1
    continue
  fi
  out="$(mktemp)"
  if bash "$ROOT/$d/tests/run.sh" 2>&1 | tee "$out"; then
    RESULT[$d]="PASS"
  else
    RESULT[$d]="FAIL"; overall=1
  fi
  TOTALS[$d]="$(grep -m1 '^#totals' "$out" | sed 's/^#totals //' || echo '-')"
  rm -f "$out"
  echo
done

echo "============================ summary ============================"
printf '%-18s %-6s %s\n' "assignment" "result" "totals"
printf '%-18s %-6s %s\n' "----------" "------" "------"
for d in $DIRS; do
  printf '%-18s %-6s %s\n' "$d" "${RESULT[$d]:-?}" "${TOTALS[$d]:-}"
done
echo "================================================================="
[ "$overall" -eq 0 ] && echo "ALL SUITES PASSED" || echo "SOME SUITES FAILED"
exit "$overall"
