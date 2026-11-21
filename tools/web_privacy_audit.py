#!/usr/bin/env python3
"""Fail closed when the browser preview gains an unreviewed device or network capability."""

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SCAN_SUFFIXES = {".gd", ".tscn", ".tres", ".godot", ".cfg", ".json", ".yml", ".yaml", ".cjs"}
ALLOWED_VOICE_REQUEST_FILES = {
    "scripts/characters/mira_npc.gd",
    "scripts/characters/world_npc_actor.gd",
}
FORBIDDEN_BROWSER_OR_DEVICE_APIS = re.compile(
    r"JavaScriptBridge|CameraServer|AudioStreamMicrophone|"
    r"OS\.execute|OS\.shell_open",
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
        line = source.count("\n", 0, match.start()) + 1
        errors.append(f"{rel}:{line}: unapproved browser/device API: {match.group(0)}")

    if "AudioStreamGenerator.new()" in source:
        if rel != "scripts/audio/nature_ambience.gd":
            errors.append(f"{rel}: procedural audio generator needs a platform-specific review")
        elif (
            'if not OS.has_feature("web"):' not in source
            or source.find('if not OS.has_feature("web"):') > source.find("AudioStreamGenerator.new()")
        ):
            errors.append(
                "scripts/audio/nature_ambience.gd: AudioStreamGenerator must remain outside the Web code path"
            )

    if "HTTPRequest.new()" in source or re.search(r"\.request\s*\(", source):
        request_files.add(rel)
        if rel not in ALLOWED_VOICE_REQUEST_FILES:
            errors.append(f"{rel}: unreviewed HTTP request capability found")
            continue

        guard = re.search(
            r'if\s+OS\.has_feature\("web"\):\s*\n\s*return',
            source,
        )
        request_call = source.find(".request(url)")
        if guard is None or request_call < 0 or guard.start() > request_call:
            errors.append(
                f"{rel}: external voice request is not blocked before request(url) on Web"
            )

web_workflow_candidates = [
    ROOT / ".github" / "workflows" / "web-preview.yml",
    ROOT / ".github" / "workflows" / "web-repair-validation.yml",
]
available_web_workflows = [path for path in web_workflow_candidates if path.is_file()]
if not available_web_workflows:
    errors.append(
        "A private Web validation workflow is missing (expected web-preview.yml "
        "or web-repair-validation.yml)"
    )
else:
    for web_workflow in available_web_workflows:
        workflow_text = web_workflow.read_text(encoding="utf-8", errors="replace")
        forbidden_publish_features = (
            "actions/upload-artifact",
            "actions/upload-pages-artifact",
            "actions/deploy-pages",
            "pages: write",
            "id-token: write",
            "deploy_pages",
        )
        for feature in forbidden_publish_features:
            if feature in workflow_text:
                errors.append(
                    f"{web_workflow.relative_to(ROOT).as_posix()}: "
                    f"public artifact/deployment capability is enabled ({feature})"
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
    print("\n".join(f"- {item}" for item in errors))
    sys.exit(1)

print("WEB PRIVACY AUDIT PASSED:")
print("- No JavaScript bridge, camera, microphone, shell, or native process API.")
print("- Only reviewed NPC voice download sites exist, and both are blocked on Web.")
print("- Large editable ambience masters remain outside Godot runtime imports.")
print("- No telemetry, file upload, or device-media integration is enabled by this audit.")
