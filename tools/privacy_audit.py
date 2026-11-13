#!/usr/bin/env python3
"""Fail CI if the project declares permissions that can expose personal device data.

This checks repository-side Android configuration only. The final exported APK/AAB
must also be inspected because Godot/plugins can contribute generated manifest entries.
"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
CONFIG_FILES = [
    ROOT / "project.godot",
    ROOT / "export_presets.cfg",
    ROOT / "android" / "AndroidManifest.xml",
    ROOT / "android" / "build" / "AndroidManifest.xml",
]
SENSITIVE_PERMISSION = re.compile(
    r"android\.permission\.(?:"
    r"CAMERA|RECORD_AUDIO|READ_MEDIA_IMAGES|READ_MEDIA_VIDEO|"
    r"READ_MEDIA_VISUAL_USER_SELECTED|READ_EXTERNAL_STORAGE|"
    r"WRITE_EXTERNAL_STORAGE|MANAGE_EXTERNAL_STORAGE|"
    r"READ_CONTACTS|WRITE_CONTACTS|GET_ACCOUNTS|"
    r"ACCESS_FINE_LOCATION|ACCESS_COARSE_LOCATION|ACCESS_BACKGROUND_LOCATION|"
    r"READ_SMS|RECEIVE_SMS|SEND_SMS|READ_CALL_LOG|WRITE_CALL_LOG|"
    r"READ_PHONE_STATE|CALL_PHONE"
    r")\b",
    re.IGNORECASE,
)

found = []
for path in CONFIG_FILES:
    if not path.is_file():
        continue
    content = path.read_text(encoding="utf-8", errors="replace")
    for match in SENSITIVE_PERMISSION.finditer(content):
        line = content.count("\n", 0, match.start()) + 1
        found.append(f"{path.relative_to(ROOT)}:{line}: {match.group(0)}")

if found:
    print("PRIVACY AUDIT FAILED: sensitive Android permission declaration(s) found:")
    print("\n".join(found))
    print("Remove the permission or document and review a genuinely required feature.")
    sys.exit(1)

print("PRIVACY AUDIT PASSED: no configured camera, microphone, media, storage,")
print("contacts, location, SMS, call-log, or phone-state permissions found.")
print("Reminder: inspect the merged manifest inside every final APK/AAB as well.")
