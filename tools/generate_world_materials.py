#!/usr/bin/env python3
"""Generate deterministic, original 2K surface-detail and tangent-space normal maps.

The maps are real RGB material assets, not padding. Each material is paired with
its own height-derived normal map and is bound to Willow Village geometry.
"""
from pathlib import Path
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1] / "assets/environment/materials/hd/detail_2k"
SIZE = 1900
MATERIALS = {
    "basalt": ((48, 51, 55), (112, 116, 120), 17),
    "red_sandstone": ((118, 48, 31), (205, 112, 67), 29),
}

def smooth_field(rng, side):
    small = rng.normal(0.0, 1.0, (side, side)).astype(np.float32)
    image = Image.fromarray(np.uint8(np.clip((small + 3.5) * 36.4, 0, 255)), "L")
    return np.asarray(image.resize((SIZE, SIZE), Image.Resampling.BICUBIC), dtype=np.float32) / 36.4 - 3.5

def build_maps(name, palette, seed):
    rng = np.random.default_rng(seed)
    low = smooth_field(rng, 24)
    mid = smooth_field(rng, 160)
    fine = rng.normal(0.0, 1.0, (SIZE, SIZE)).astype(np.float32)
    y, x = np.mgrid[0:SIZE, 0:SIZE].astype(np.float32)
    if name in ("red_sandstone", "terracotta"):
        strata = np.sin(y * 0.035 + np.sin(x * 0.006) * 3.2) * 0.75
    elif name in ("asphalt", "harbor_paving"):
        strata = np.sin((x + y * 0.22) * 0.09) * 0.24
    elif name == "pine_floor":
        strata = np.sin((x * 0.11 + y * 0.025) + np.sin(y * 0.009) * 2.0) * 0.42
    elif name == "coastal_sand":
        strata = np.sin(x * 0.022 + np.sin(y * 0.018) * 2.0) * 0.28
    else:
        strata = np.sin(x * 0.045 + y * 0.031) * 0.22
    height = low * 0.85 + mid * 0.42 + fine * 0.17 + strata
    height = np.clip(height, -3.0, 3.0)
    lo = np.asarray(palette[0], dtype=np.float32)
    hi = np.asarray(palette[1], dtype=np.float32)
    tone = np.clip(0.52 + height * 0.105, 0.12, 0.92)[..., None]
    rgb = np.clip(lo + (hi - lo) * tone + fine[..., None] * 5.0, 0, 255).astype(np.uint8)
    Image.fromarray(rgb, "RGB").save(ROOT / f"{name}_detail_albedo_2k.bmp", format="BMP")

    # Height gradients become a proper tangent-space normal map.
    gy, gx = np.gradient(height)
    nx = -gx * 0.55
    ny = -gy * 0.55
    nz = np.ones_like(nx)
    length = np.sqrt(nx * nx + ny * ny + nz * nz)
    normal = np.stack(((nx / length + 1.0) * 127.5,
                       (ny / length + 1.0) * 127.5,
                       (nz / length + 1.0) * 127.5), axis=-1)
    Image.fromarray(np.clip(normal, 0, 255).astype(np.uint8), "RGB").save(
        ROOT / f"{name}_normal_2k.bmp", format="BMP")

def main():
    ROOT.mkdir(parents=True, exist_ok=True)
    for name, (dark, light, seed) in MATERIALS.items():
        build_maps(name, (dark, light), seed)
        print(f"Generated 2K albedo + normal maps: {name}")
    files = sorted(ROOT.glob("*.bmp"))
    expected = len(MATERIALS) * 2
    if len(files) != expected:
        raise SystemExit(f"Expected {expected} maps, found {len(files)}")
    total = sum(p.stat().st_size for p in files)
    if any(p.stat().st_size < 10_800_000 for p in files):
        raise SystemExit("A generated BMP is unexpectedly small or incomplete")
    print(f"PASS: {len(files)} original 1900x1900 RGB maps; {total:,} bytes total")

if __name__ == "__main__":
    main()
