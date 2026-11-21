#!/usr/bin/env python3
"""Validate Wavefront OBJ material-library references in project assets.

The validator checks both sides of the OBJ/MTL contract:
- every mtllib path exists beside the referencing OBJ (relative paths supported);
- every usemtl name is defined by one of that OBJ's referenced libraries.
"""
from __future__ import annotations

import shlex
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSET_ROOT = ROOT / "assets"


def parse_mtl(path: Path) -> set[str]:
    materials: set[str] = set()
    with path.open("r", encoding="utf-8", errors="replace") as handle:
        for raw_line in handle:
            stripped = raw_line.strip()
            if not stripped or stripped.startswith("#"):
                continue
            if stripped.lower().startswith("newmtl "):
                parts = shlex.split(stripped, comments=False, posix=True)
                if len(parts) >= 2:
                    materials.add(" ".join(parts[1:]))
    return materials


def validate_obj(path: Path) -> list[str]:
    errors: list[str] = []
    library_paths: list[Path] = []
    used_materials: set[str] = set()

    with path.open("r", encoding="utf-8", errors="replace") as handle:
        for line_number, raw_line in enumerate(handle, start=1):
            stripped = raw_line.strip()
            if not stripped or stripped.startswith("#"):
                continue
            directive = stripped.split(maxsplit=1)[0].lower()
            if directive == "mtllib":
                try:
                    names = shlex.split(stripped[len("mtllib"):].strip(), comments=False)
                except ValueError as exc:
                    errors.append(f"{path.relative_to(ROOT)}:{line_number}: invalid mtllib syntax: {exc}")
                    continue
                for name in names:
                    normalized = name.replace("\\", "/")
                    library = (path.parent / normalized).resolve()
                    if not library.is_file():
                        errors.append(
                            f"{path.relative_to(ROOT)}:{line_number}: missing material library {name!r}"
                        )
                    else:
                        library_paths.append(library)
            elif directive == "usemtl":
                material_name = stripped[len("usemtl"):].strip()
                if material_name:
                    used_materials.add(material_name)

    available: set[str] = set()
    for library in library_paths:
        try:
            available.update(parse_mtl(library))
        except OSError as exc:
            errors.append(f"{library.relative_to(ROOT)}: cannot read material library: {exc}")

    for material_name in sorted(used_materials - available):
        errors.append(
            f"{path.relative_to(ROOT)}: material {material_name!r} is not defined in its mtllib file(s)"
        )
    return errors


def main() -> int:
    object_files = sorted(ASSET_ROOT.rglob("*.obj"))
    if not object_files:
        print("No OBJ assets found under assets/.")
        return 0

    errors: list[str] = []
    for obj_path in object_files:
        errors.extend(validate_obj(obj_path))

    if errors:
        print(f"OBJ/MTL validation failed: {len(errors)} issue(s) across {len(object_files)} OBJ file(s).")
        for error in errors:
            print(f"ERROR: {error}")
        return 1

    print(f"OBJ/MTL validation passed: {len(object_files)} OBJ file(s), all libraries and usemtl names resolved.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
