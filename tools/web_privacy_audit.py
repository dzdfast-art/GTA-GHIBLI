#!/usr/bin/env python3
"""Fail closed when the browser preview gains an unreviewed device or network capability."""

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SCAN_SUFFIXES = {".gd", ".tscn", ".tres", ".godot", ".cfg", ".json"}
ALLOWED_VOICE_REQUEST_FILES = {
    "scripts/characters/mira_npc.gd",
    "scripts/characters/world_npc_actor.gd",
}
FORBIDDEN_BROWSER_OR_DEVICE_APIS = re.compile(
    r"JavaScriptBridge|CameraServer|AudioStreamMicrophone|"
    r"OS\\.execute|OS\\.shell_open",
    re.IGNORECASE,
)

errors = []
request_files = set()

for path in ROOT.rglob("*"):
    if not path.is_file() or path.suffix.lower() not in SCAN_SUFFIXES:
        continue
    if ".git" in path.parts or ".godot" in path.parts or "build" in path.parts:
        continue

    rel = path.relative_to(ROOT).as_posix()
    source = path.read_text(encoding="utf-8", errors="replace")

    for match in FORBIDDEN_BROWSER_OR_DEVICE_APIS.finditer(source):
        line = source.count("\\n", 0, match.start()) + 1
        errors.append(f"{rel}:{line}: unapproved browser/device API: {match.group(0)}")

    if "HTTPRequest.new()" in source or re.search(r"\\.request\\s*\\(", source):
        request_files.add(rel)
        if rel not in ALLOWED_VOICE_REQUEST_FILES:
            errors.append(f"{rel}: unreviewed HTTP request capability found")
            continue

        guard = re.search(
            r'if\\s+OS\\.has_feature\\("web"\\):\\s*\\n\\s*return',
            source,
        )
        request_call = source.find(".request(url)")
        if guard is None or request_call < 0 or guard.start() > request_call:
            errors.append(
                f"{rel}: external voice request is not blocked before request(url) on Web"
            )

expected_master_guard = ROOT / "audio" / "ambience" / "source_master" / ".gdignore"
if not expected_master_guard.is_file():
    errors.append(
        "audio/ambience/source_master/.gdignore is missing; large editable masters "
        "must stay outside Godot runtime imports"
    )

unexpected = request_files - ALLOWED_VOICE_REQUEST_FILES
if unexpected:
    errors.append("Unexpected request files: " + ", ".join(sorted(unexpected)))

if errors:
    print("WEB PRIVACY AUDIT FAILED:")
    print("\\n".join(f"- {item}" for item in errors))
    sys.exit(1)

print("WEB PRIVACY AUDIT PASSED:")
print("- No JavaScript bridge, camera, microphone, shell, or native process API.")
print("- Only reviewed NPC voice download sites exist, and both are blocked on Web.")
print("- Large editable ambience masters remain outside Godot runtime imports.")
print("- No telemetry, file upload, or device-media integration is enabled by this audit.")
