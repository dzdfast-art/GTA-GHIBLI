#!/usr/bin/env python3
"""Ensure Web dialogue playback never falls through to external HTTP audio requests."""

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
CHECKS = {
    "scripts/characters/world_npc_actor.gd": (
        'var url := str(line.get("audio_url",""))',
        "if OS.has_feature(\"web\"):",
        "_voice_request.request(url)",
    ),
    "scripts/characters/mira_npc.gd": (
        'var url:=str(_greeting.get("audio_url",""))',
        "if OS.has_feature(\"web\"):",
        "_voice_request.request(url)",
    ),
}


def main() -> int:
    errors: list[str] = []
    for relative_path, markers in CHECKS.items():
        path = ROOT / relative_path
        if not path.is_file():
            errors.append(f"Missing dialogue script: {relative_path}")
            continue
        source = path.read_text(encoding="utf-8")
        positions = [source.find(marker) for marker in markers]
        if any(position < 0 for position in positions):
            errors.append(f"{relative_path}: missing Web audio guard or request marker")
            continue
        url_position, guard_position, request_position = positions
        if not url_position < guard_position < request_position:
            errors.append(f"{relative_path}: Web guard must be after URL validation and before HTTPRequest")
            continue
        guard_block = source[guard_position:request_position]
        if "return" not in guard_block:
            errors.append(f"{relative_path}: Web guard does not exit before the external request")
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print(f"PASS: Web external dialogue audio requests blocked in {len(CHECKS)} character scripts.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
