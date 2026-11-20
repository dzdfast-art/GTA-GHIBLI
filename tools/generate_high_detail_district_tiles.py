#!/usr/bin/env python3
"""Generate four deterministic district-edge terrain OBJ meshes.
Run from the repository root: python tools/generate_high_detail_district_tiles.py
"""
from __future__ import annotations
import math
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets/environment/terrain/high_detail"
SIZE = 112

def gaussian(value: float, center: float, width: float) -> float:
    return math.exp(-((value - center) / width) ** 2)

def height_at(kind: str, x: float, z: float) -> float:
    wave = 0.42 * math.sin(x*0.071+z*0.023) + 0.31 * math.cos(z*0.063-x*0.019) + 0.17 * math.sin((x+z)*0.13)
    if kind == "harbor":
        return 1.25+0.62*math.sin(x*0.032)+0.36*math.cos(z*0.041)+3.2*gaussian(z,43,10)+4.1*gaussian(z,178,12)-1.25*gaussian(z,110,22)+wave*0.45
    if kind == "pine":
        return 2.0+17.0*gaussian(x,104,22)+8.4*gaussian(x,169,18)+2.1*gaussian(z,38,24)+1.2*math.sin(z*0.052)+wave*0.7
    if kind == "amber":
        bx=(x+8*math.sin(z*0.028)+444)%38
        bz=(z+7*math.cos(x*0.025)+444)%48
        terraces=1.8*math.floor((x+8*math.sin(z*0.028))/38)+1.15*math.floor((z+7*math.cos(x*0.025))/48)+0.42*(1-math.cos(2*math.pi*bx/38))+0.28*(1-math.cos(2*math.pi*bz/48))
        drainage=-1.1*gaussian(z,82+8*math.sin(x*0.03),7)-0.8*gaussian(z,166,6)
        return 1.8+terraces+0.05*x+drainage+wave*0.3
    return 0.95+6.2*gaussian(x,62,27)+4.7*gaussian(x,166,21)-1.5*gaussian(z,107,18)-1.1*gaussian(math.hypot(x-124,z-72),0,19)+0.48*math.sin(z*0.075)+wave*0.55

def row_material(kind: str, row: int) -> str:
    """Use broad contiguous material bands to stay under the 256-surface import cap."""
    z = row * 2.0
    if kind == "harbor":
        if 34.0 <= z <= 54.0:
            return "ground_rock"
        if 92.0 <= z <= 128.0:
            return "ground_water_edge"
        if z < 24.0 or z > 190.0:
            return "ground_dirt"
        return "ground_sand"
    if kind == "pine":
        return "ground_rock" if 36.0 <= z <= 82.0 else "ground_forest"
    if kind == "amber":
        if 78.0 <= z <= 94.0 or 160.0 <= z <= 176.0:
            return "ground_water_edge"
        return "ground_crop" if int(z // 48) % 2 == 0 else "ground_soil"
    if z < 28.0 or z > 190.0:
        return "ground_rock"
    if 88.0 <= z <= 126.0:
        return "ground_water_edge"
    return "ground_sand"

def build_tile(kind: str, filename: str, label: str) -> None:
    heights=[[height_at(kind,col*2.0,row*2.0) for col in range(SIZE)] for row in range(SIZE)]
    lines=[f"# GTA GHIBLI original high-detail {label} terrain tile","mtllib high_detail_terrain.mtl","s off"]
    for row in range(SIZE):
        for col in range(SIZE): lines.append(f"v {col*2.0:.3f} {heights[row][col]:.3f} {row*2.0:.3f}")
    active=""
    for row in range(SIZE-1):
        material=row_material(kind,row)
        if material!=active:
            lines.append(f"usemtl {material}")
            active=material
        for col in range(SIZE-1):
            a=row*SIZE+col+1
            b=(row+1)*SIZE+col+1
            c=row*SIZE+col+2
            d=(row+1)*SIZE+col+2
            lines.extend((f"f {a} {b} {c}",f"f {c} {b} {d}"))
    (OUT/filename).write_text("\n".join(lines)+"\n",encoding="utf-8")

def main() -> None:
    OUT.mkdir(parents=True,exist_ok=True)
    build_tile("harbor","harbor_breakwater_112.obj","harbor breakwater")
    build_tile("pine","pine_granite_spur_112.obj","pine granite spur")
    build_tile("amber","amber_vineyard_terraces_112.obj","amber vineyard terraces")
    build_tile("sapphire","sapphire_tidepool_rim_112.obj","sapphire tidepool rim")
    print("Generated four original 112x112 district terrain meshes.")

if __name__ == "__main__":
    main()
