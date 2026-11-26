#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
log_file="$(mktemp)"
trap 'rm -f "$log_file"' EXIT

test_status=0
if timeout 180s godot --headless --verbose --path . --script res://tests/main_scene_smoke_test.gd >"$log_file" 2>&1; then
  test_status=0
else
  test_status=$?
fi

cat "$log_file"
if (( test_status != 0 )); then
  echo "::error::Main-scene smoke test exited with status $test_status."
  exit "$test_status"
fi

if grep -Eqi 'SCRIPT ERROR:|Parse Error:|ERROR:|WARNING: [0-9]+ RID .* leaked|WARNING: [0-9]+ ObjectDB instances were leaked|[0-9]+ resources still in use at exit' "$log_file"; then
  echo "::error::Main-scene smoke test logged a parser, runtime, or resource-cleanup error."
  exit 1
fi

if ! grep -Fq 'PASS: main.tscn instantiates the player' "$log_file"; then
  echo "::error::Main-scene smoke test exited without its explicit PASS marker."
  exit 1
fi

echo "PASS: main-scene smoke test completed with clean resource teardown."
