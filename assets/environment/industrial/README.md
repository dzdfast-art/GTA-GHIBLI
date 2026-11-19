# Harbor gantry crane asset pack | حزمة رافعة الميناء

- `harbor_gantry_crane.obj`: original low-poly gantry frame, bogies, wheel sets, portal legs, cross-bracing, access ladders, operator cabin, boom trusses, trolley rails, warning details and service hardware.
- `harbor_gantry_crane.mtl`: material groups and atlas references.
- `harbor_industrial_atlas.svg`: original 2048×2048 four-quadrant surface atlas for weathered steel, red industrial paint, hazard striping and tinted glass.

All geometry and texture artwork in this pack were authored for GTA GHIBLI. No third-party game assets, commercial-game rips, or personal files are used.

Runtime path: `scenes/world/harbor_gantry_crane.tscn`, instantiated by `scripts/world/open_world_regions.gd` in Harbor City. The suspended cargo is created by `scripts/world/harbor_gantry_crane.gd`; the existing shared interaction action toggles the hoist between low and raised positions.

Mobile note: the frame is one imported mesh with six material groups; only the four support legs have static collision. The suspended container is a lightweight runtime mesh, not a rigid body.
