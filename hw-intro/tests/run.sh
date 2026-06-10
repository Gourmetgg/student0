#!/usr/bin/env bash
# Thin entry point — all logic lives in <repo>/tests/runner.sh + tests/lib.sh.
HERE="$(cd "$(dirname "$0")" && pwd)"
exec bash "$HERE/../../tests/runner.sh" "$(dirname "$HERE")" "$@"
