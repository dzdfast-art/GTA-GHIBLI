#!/usr/bin/env python3
"""Validate that imported game assets have traceable licenses and real files.

Only entries marked "integrated" are required to exist in the repository.
Research-only candidates are deliberately excluded from the shipped asset set.
"""
from __future__ import annotations

import json
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "assets" / "asset_manifest.json"


def fail(message: str) -> None:
    print(f"ASSET AUDIT FAIL: {message}", file=sys.stderr)
    raise SystemExit(1)


def safe_repo_path(raw: str) -> Path:
    candidate = (ROOT / raw).resolve()
    if candidate != ROOT and ROOT not in candidate.parents:
        fail(f"path escapes repository: {raw}")
    return candidate


def validate_glb(path: Path) -> None:
    with path.open("rb") as stream:
        header = stream.read(12)
    if len(header) != 12:
        fail(f"GLB header is incomplete: {path.relative_to(ROOT)}")
    magic, version, declared_length = struct.unpack("<4sII", header)
    if magic != b"glTF":
        fail(f"invalid GLB magic in {path.relative_to(ROOT)}")
    if version != 2:
        fail(f"unsupported GLB version {version} in {path.relative_to(ROOT)}")
    if declared_length != path.stat().st_size:
        fail(
            f"GLB length mismatch for {path.relative_to(ROOT)}: "
            f"header={declared_length}, actual={path.stat().st_size}"
        )


def main() -> None:
    if not MANIFEST.is_file():
        fail("assets/asset_manifest.json is missing")

    try:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot read asset manifest: {exc}")

    if manifest.get("schema_version") != 1:
        fail("unsupported asset manifest schema_version")

    assets = manifest.get("assets")
    if not isinstance(assets, list):
        fail("manifest 'assets' must be an array")

    seen_ids: set[str] = set()
    integrated_count = 0
    for asset in assets:
        asset_id = asset.get("id")
        if not asset_id or asset_id in seen_ids:
            fail(f"missing or duplicate asset id: {asset_id!r}")
        seen_ids.add(asset_id)

        if asset.get("status") != "integrated":
            continue

        integrated_count += 1
        if asset.get("license") not in {"CC0-1.0", "CC-BY-4.0", "MIT"}:
            fail(f"unapproved or unverified license for {asset_id}: {asset.get('license')}")

        asset_path = safe_repo_path(str(asset.get("path", "")))
        license_path = safe_repo_path(str(asset.get("license_file", "")))
        if not asset_path.is_file():
            fail(f"integrated asset file is missing: {asset.get('path')}")
        if asset_path.stat().st_size <= 0:
            fail(f"integrated asset is empty: {asset.get('path')}")
        if not license_path.is_file():
            fail(f"license file is missing for {asset_id}: {asset.get('license_file')}")

        license_text = license_path.read_text(encoding="utf-8", errors="replace").lower()
        if asset.get("license") == "CC0-1.0" and "cc0 1.0" not in license_text:
            fail(f"license file does not identify CC0 1.0 for {asset_id}")

        if asset.get("format", "").lower() == "glb":
            validate_glb(asset_path)

        print(
            f"PASS: {asset_id} | {asset_path.stat().st_size:,} bytes | "
            f"{asset['license']} | {asset_path.relative_to(ROOT)}"
        )

    if integrated_count == 0:
        fail("no integrated assets were validated")

    print(
        f"PASS: validated {integrated_count} integrated asset(s); "
        f"{len(manifest.get('candidates', []))} research-only candidate(s) were not counted as shipped content."
    )


if __name__ == "__main__":
    main()
