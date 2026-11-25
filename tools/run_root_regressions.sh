#!/usr/bin/env bash
set -uo pipefail

ROOT="$GITHUB_WORKSPACE"
cd "$ROOT"

mapfile -t scripts < <(find tests -maxdepth 1 -type f -name '*_test.gd' -print | sort)
if [[ ${#scripts[@]} -eq 0 ]]; then
  echo "::error::No root GDScript regression tests were discovered."
  exit 1
fi

failed=0
for script in "${scripts[@]}"; do
  log_file="$(mktemp)"
  echo "::group::Godot regression: $script"
  set +e
  timeout 180s godot --headless --path "$ROOT" --script "res://$script" >"$log_file" 2>&1
  status=$?
  set -e
  if [[ "$status" -ne 0 ]] || grep -Eqi 'SCRIPT ERROR:|Parse Error:|Assertion failed|Invalid call[.]' "$log_file"; then
    echo "::error::$script failed (exit=$status or runtime/assertion error in log)."
    tail -n 100 "$log_file"
    failed=$((failed + 1))
  else
    echo "PASS: $script (exit=0; no GDScript/runtime assertion diagnostics)"
  fi
  rm -f "$log_file"
  echo "::endgroup::"
done

echo "${#scripts[@]} root tests executed; $failed failed."
if [[ "$failed" -ne 0 ]]; then
  exit 1
fi
