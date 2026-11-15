#!/usr/bin/env python3
"""Validate the original high-detail OBJ terrain source assets for Godot import safety.

The OBJ importer creates a mesh surface at material boundaries. Repeatedly switching
between the same materials can exceed Godot's per-mesh surface limit, so each material
must appear in one contiguous face block per OBJ file.
"""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
TERRAIN_DIR = ROOT / "assets" / "environment" / "terrain" / "high_detail"
MATERIAL_FILE = TERRAIN_DIR / "high_detail_terrain.mtl"
EXPECTED_VERTEX_COUNT = 12_544
EXPECTED_FACE_COUNT = 24_642
MAX_MATERIAL_SURFACES = 8


def fail(message: str) -> None:
    print(f"OBJ TERRAIN AUDIT FAILED: {message}")
    raise SystemExit(1)


if not MATERIAL_FILE.is_file():
    fail("high_detail_terrain.mtl is missing")

declared_materials = {
    line.split(maxsplit=1)[1].strip()
    for line in MATERIAL_FILE.read_text(encoding="utf-8").splitlines()
    if line.startswith("newmtl ")
}
obj_files = sorted(TERRAIN_DIR.glob("*_112.obj"))
if len(obj_files) != 23:
    fail(f"expected 23 high-detail terrain meshes, found {len(obj_files)}")

for path in obj_files:
    content = path.read_text(encoding="utf-8")
    if "mtllib high_detail_terrain.mtl" not in content:
        fail(f"{path.name} does not reference the shared material library")

    vertex_count = 0
    face_count = 0
    material_order = []
    current_material = None
    closed_materials = set()

    for line_number, line in enumerate(content.splitlines(), start=1):
        if line.startswith("v "):
            vertex_count += 1
        elif line.startswith("usemtl "):
            material = line.split(maxsplit=1)[1].strip()
            if material in closed_materials:
                fail(f"{path.name}:{line_number} repeats material block {material!r}")
            if current_material is not None:
                closed_materials.add(current_material)
            current_material = material
            material_order.append(material)
            if material not in declared_materials:
                fail(f"{path.name}:{line_number} uses undeclared material {material!r}")
        elif line.startswith("f "):
            if current_material is None:
                fail(f"{path.name}:{line_number} has a face before its material")
            face_count += 1

    if vertex_count != EXPECTED_VERTEX_COUNT:
        fail(f"{path.name} has {vertex_count} vertices, expected {EXPECTED_VERTEX_COUNT}")
    if face_count != EXPECTED_FACE_COUNT:
        fail(f"{path.name} has {face_count} faces, expected {EXPECTED_FACE_COUNT}")
    if not material_order or len(material_order) > MAX_MATERIAL_SURFACES:
        fail(f"{path.name} has unsafe material surface count: {len(material_order)}")

    print(
        f"PASS {path.name}: {vertex_count:,} vertices, {face_count:,} faces, "
        f"{len(material_order)} contiguous material surfaces"
    )

print(f"OBJ TERRAIN AUDIT PASSED: {len(obj_files)} original terrain meshes are import-safe.")
