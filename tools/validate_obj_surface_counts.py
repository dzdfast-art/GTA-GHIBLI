#!/usr/bin/env python3
"""Fail CI when an imported OBJ would exceed Godot's mesh-surface limit.

Godot creates surfaces for material runs within OBJ objects. The limit applies
to the resulting mesh, so count surfaces across the entire file, not separately
inside each object.
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

    with obj_path.open("r", encoding="utf-8", errors="replace") as source:
        for raw_line in source:
            line = raw_line.strip()
            if line.startswith("o "):
                object_name = line[2:].strip() or "<unnamed>"
                last_face_material = object()
            elif line.startswith("usemtl "):
                current_material = line[7:].strip()
            elif line.startswith("f "):
                if current_material != last_face_material:
                    surface_count += 1
                    last_face_material = current_material

    if surface_count > MAX_MESH_SURFACES:
        failures.append(
            f"{obj_path.relative_to(ROOT)}: {surface_count} material surfaces "
            f"across OBJ objects (limit {MAX_MESH_SURFACES}; last object {object_name})"
        )

if failures:
    print("OBJ mesh-surface budget violations:")
    for failure in failures:
        print(f" - {failure}")
    raise SystemExit(1)

print(f"PASS: checked {checked} OBJ files; no imported mesh exceeds {MAX_MESH_SURFACES} surfaces.")
