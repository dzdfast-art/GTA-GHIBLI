#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
shopt -s nullglob
tests=(tests/*_test.gd)
if (("${#tests[@]}" == 0)); then
  echo "::error::No root GDScript regression tests were discovered."
  exit 1
fi

failed=0
for test_file in "${tests[@]}"; do
  test_name="${test_file##*/}"
  test_log="$(mktemp)"
  timeout_seconds=60
  case "$test_name" in
    terrain_expansion_runtime_test.gd|video_reference_world_flow_test.gd)
      timeout_seconds=240
      ;;
  esac

  echo "::group::Running $test_name (timeout ${timeout_seconds}s)"
  test_status=0
  if timeout "${timeout_seconds}s" godot --headless --path . --script "res://$test_file" >"$test_log" 2>&1; then
    test_status=0
  else
    test_status=$?
  fi
  cat "$test_log"

  if (( test_status != 0 )); then
    echo "::error::$test_name exited with status $test_status."
    failed=$((failed + 1))
  elif grep -Eqi 'ERROR:|SCRIPT ERROR:|Parse Error:|Assertion failed|Invalid call[.]|Failed loading resource' "$test_log"; then
    echo "::error::$test_name logged a script, parser, assertion, invalid-call, or resource-load error."
    failed=$((failed + 1))
  elif ! grep -Eqi 'PASS([: |]|$)' "$test_log"; then
    echo "::error::$test_name exited without an explicit PASS marker."
    failed=$((failed + 1))
  else
    echo "PASS: $test_name"
  fi

  rm -f "$test_log"
  echo "::endgroup::"
done

echo "${#tests[@]} root regression tests; $failed failures."
if (( failed != 0 )); then
  exit 1
fi
