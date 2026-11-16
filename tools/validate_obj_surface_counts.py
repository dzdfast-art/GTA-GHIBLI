#!/usr/bin/env python3
"""Fail CI when an OBJ object exceeds Godot's mesh-surface limit.

Godot creates a surface for each contiguous material run in an OBJ object.
Repeatedly alternating usemtl directives can silently exceed the engine limit
and flood the import log with RenderingServer MAX_MESH_SURFACES errors.
"""
from pathlib import Path

MAX_MESH_SURFACES = 256
ROOT = Path(__file__).resolve().parents[1]
ASSET_ROOT = ROOT / "assets"
failures = []
checked = 0

for obj_path in sorted(ASSET_ROOT.rglob("*.obj")):
    checked += 1
    object_name = "<default>"
    current_material = None
    last_face_material = object()
    surface_count = 0

    def check_object() -> None:
        if surface_count > MAX_MESH_SURFACES:
            failures.append(
                f"{obj_path.relative_to(ROOT)} :: {object_name}: "
                f"{surface_count} material surfaces (limit {MAX_MESH_SURFACES})"
            )

    with obj_path.open("r", encoding="utf-8", errors="replace") as source:
        for raw_line in source:
            line = raw_line.strip()
            if line.startswith("o "):
                check_object()
                object_name = line[2:].strip() or "<unnamed>"
                current_material = None
                last_face_material = object()
                surface_count = 0
            elif line.startswith("usemtl "):
                current_material = line[7:].strip()
            elif line.startswith("f "):
                if current_material != last_face_material:
                    surface_count += 1
                    last_face_material = current_material
    check_object()

if failures:
    print("OBJ mesh-surface budget violations:")
    for failure in failures:
        print(f" - {failure}")
    raise SystemExit(1)

print(f"PASS: checked {checked} OBJ files; no object exceeds {MAX_MESH_SURFACES} material surfaces.")
