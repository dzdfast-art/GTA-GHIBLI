#!/usr/bin/env python3
"""Fetch verified free Standard Quaternius animation packs from itch.io.

Only the anonymous, no-payment Standard uploads are downloaded. The official
archive sizes and SHA-256 digests are pinned below. Paid Source/Pro packages
are never requested.
"""
from __future__ import annotations

import hashlib
import json
import re
import struct
import sys
import tempfile
import urllib.error
import urllib.parse
import urllib.request
import http.cookiejar
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets" / "animations"
USER_AGENT = "GTA-GHIBLI-CC0-Asset-Downloader/1.0"

PACKS = (
    {
        "id": "quaternius_ual1_standard",
        "slug": "universal-animation-library",
        "upload_id": "17958403",
        "archive_name": "Universal Animation Library[Standard].zip",
        "expected_size": 15_904_933,
        "sha256": "cc73fc4e495b82958207316596317a3f40b9fa38065bde1027937452da537724",
        "glb_suffix": "/Unreal-Godot/UAL1_Standard.glb",
        "output_glb": "ual1_standard.glb",
        "output_license": "UAL1-CC0-LICENSE.txt",
    },
    {
        "id": "quaternius_ual2_standard",
        "slug": "universal-animation-library-2",
        "upload_id": "17958478",
        "archive_name": "Universal Animation Library 2[Standard].zip",
        "expected_size": 18_735_003,
        "sha256": "4008ea208a604773a2b2177d965f0f5d3195498b5bf838c3f5785d68e95f2a68",
        "glb_suffix": "/Unreal-Godot/UAL2_Standard.glb",
        "output_glb": "ual2_standard.glb",
        "output_license": "UAL2-CC0-LICENSE.txt",
    },
)


def request_bytes(
    opener: urllib.request.OpenerDirector,
    url: str,
    *,
    data: bytes | None = None,
    referer: str | None = None,
    timeout: int = 90,
) -> bytes:
    headers = {"User-Agent": USER_AGENT}
    if referer:
        headers["Referer"] = referer
    if data is not None:
        headers["Content-Type"] = "application/x-www-form-urlencoded"
    request = urllib.request.Request(url, data=data, headers=headers)
    try:
        with opener.open(request, timeout=timeout) as response:
            return response.read()
    except (urllib.error.URLError, TimeoutError) as exc:
        raise RuntimeError(f"Could not retrieve {url}: {exc}") from exc


def csrf_token(page: bytes, url: str) -> str:
    html = page.decode("utf-8", errors="replace")
    match = re.search(
        r'<meta\s+name=["\']csrf_token["\']\\s+(?:value|content)=["\']([^"\']+)',
        html,
        flags=re.IGNORECASE,
    )
    if not match:
        raise RuntimeError(f"itch.io CSRF token was not present on {url}")
    return match.group(1)


def itch_signed_download(pack: dict[str, object], opener: urllib.request.OpenerDirector) -> str:
    base = f"https://quaternius.itch.io/{pack['slug']}"
    purchase_url = f"{base}/purchase"
    purchase_page = request_bytes(opener, purchase_url)
    purchase_token = csrf_token(purchase_page, purchase_url)

    form = urllib.parse.urlencode({"csrf_token": purchase_token}).encode("ascii")
    generated_raw = request_bytes(opener, f"{base}/download_url", data=form, referer=purchase_url)
    try:
        generated = json.loads(generated_raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"itch.io did not return its free-download page for {pack['id']}") from exc
    landing_url = generated.get("url")
    if not isinstance(landing_url, str) or not landing_url.startswith("https://"):
        raise RuntimeError(f"itch.io free-download URL was missing for {pack['id']}")

    landing_page = request_bytes(opener, landing_url)
    landing_token = csrf_token(landing_page, landing_url)
    file_url = f"{base}/file/{pack['upload_id']}?source=game_download"
    file_form = urllib.parse.urlencode({"csrf_token": landing_token}).encode("ascii")
    file_raw = request_bytes(opener, file_url, data=file_form, referer=landing_url)
    try:
        file_result = json.loads(file_raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"itch.io did not issue the Standard file URL for {pack['id']}") from exc
    signed_url = file_result.get("url")
    if not isinstance(signed_url, str) or not signed_url.startswith("https://"):
        raise RuntimeError(f"itch.io signed archive URL was missing for {pack['id']}")
    return signed_url


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate_glb(data: bytes, label: str) -> None:
    if len(data) < 12:
        raise RuntimeError(f"{label} GLB is shorter than its header")
    magic, version, declared_size = struct.unpack("<4sII", data[:12])
    if magic != b"glTF" or version != 2 or declared_size != len(data):
        raise RuntimeError(
            f"{label} GLB header mismatch: magic={magic!r}, version={version}, "
            f"declared={declared_size}, actual={len(data)}"
        )


def extract_pack(pack: dict[str, object], archive: Path) -> tuple[Path, Path]:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    glb_suffix = str(pack["glb_suffix"]).casefold()
    with zipfile.ZipFile(archive) as zipped:
        bad_entry = zipped.testzip()
        if bad_entry is not None:
            raise RuntimeError(f"Corrupt ZIP entry in {archive.name}: {bad_entry}")
        names = zipped.namelist()
        glb_members = [name for name in names if name.casefold().endswith(glb_suffix)]
        license_members = [
            name for name in names
            if name.casefold().endswith("/license.txt") or name.casefold() == "license.txt"
        ]
        if len(glb_members) != 1:
            raise RuntimeError(
                f"Expected exactly one {glb_suffix} in {archive.name}; found {len(glb_members)}"
            )
        if not license_members:
            raise RuntimeError(f"Original License.txt was not present in {archive.name}")
        glb_data = zipped.read(glb_members[0])
        license_data = zipped.read(license_members[0])

    validate_glb(glb_data, str(pack["id"]))
    license_text = license_data.decode("utf-8", errors="replace").casefold()
    if "cc0 1.0" not in license_text and "creative commons zero" not in license_text:
        raise RuntimeError(f"Original license file does not identify CC0 1.0: {archive.name}")

    glb_path = OUTPUT / str(pack["output_glb"])
    license_path = OUTPUT / str(pack["output_license"])
    glb_path.write_bytes(glb_data)
    license_path.write_bytes(license_data)
    return glb_path, license_path


def main() -> int:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    cookie_jar = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cookie_jar))
    summary = []

    for pack in PACKS:
        with tempfile.TemporaryDirectory(prefix="gtaghibli-ual-") as temp_dir:
            archive = Path(temp_dir) / str(pack["archive_name"])
            signed_url = itch_signed_download(pack, opener)
            archive_data = request_bytes(opener, signed_url, referer=f"https://quaternius.itch.io/{pack['slug']}", timeout=240)
            archive.write_bytes(archive_data)

            actual_size = archive.stat().st_size
            actual_sha = sha256_file(archive)
            if actual_size != int(pack["expected_size"]):
                raise RuntimeError(
                    f"{pack['id']} size mismatch: expected {pack['expected_size']}, got {actual_size}"
                )
            if actual_sha != str(pack["sha256"]):
                raise RuntimeError(
                    f"{pack['id']} SHA-256 mismatch: expected {pack['sha256']}, got {actual_sha}"
                )

            glb_path, license_path = extract_pack(pack, archive)
            summary.append({
                "id": pack["id"],
                "archive_bytes": actual_size,
                "archive_sha256": actual_sha,
                "glb_path": glb_path.relative_to(ROOT).as_posix(),
                "glb_bytes": glb_path.stat().st_size,
                "license_path": license_path.relative_to(ROOT).as_posix(),
            })
            print(
                f"PASS: {pack['id']} archive {actual_size:,} bytes SHA-256 verified; "
                f"extracted {glb_path.stat().st_size:,}-byte GLB and original CC0 license."
            )

    print(json.dumps(summary, indent=2))
    print("PASS: official free Standard UAL1 and UAL2 archives downloaded; no account or payment was used.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"QUATERNIUS ANIMATION DOWNLOAD FAILED: {exc}", file=sys.stderr)
        raise SystemExit(1)
