# GTA GHIBLI — High-detail terrain integration

All 23 original high-detail OBJ terrain tiles already tracked under `assets/environment/terrain/high_detail/` are now assigned to the four world districts.

| District | Tiles | Landscape themes |
|---|---:|---|
| Harbor City | 6 | harbor flats, river delta, wetland, urban canal/park and basalt coast |
| Pine Highlands | 6 | forest floor, plateau, ravine, granite ridge, mountain pass and badlands |
| Amber Valley | 6 | meadow, farm fields, orchard hills/slope, desert wash and red canyon |
| Sapphire Coast | 5 | coastal grass/cliffs, sapphire headland, lake shore and willow marsh |
| **Total** | **23** | **all source tiles assigned once** |

The source OBJ meshes each use a 112 x 112 vertex grid and a shared material library. Terrain chunks are scaled into an approximately 40-unit square grid per district, with a conservative vertical scale. A visibility distance is applied to limit distant chunk rendering. The ground collision and district pads remain as blockout surfaces; terrain collision proxies and seamless border blending are not yet implemented.

The importer helper supports both Godot resource results commonly used for OBJ imports: `PackedScene` and `Mesh`. The terrain test asserts all 23 source resources are loaded and that every district has a minimum of five chunks. The shared MTL library also includes the crop material used by the farm-field tile.

The world ground plane and collision footprint were expanded to 300 x 240 units to fit the four district terrain clusters.

## Remaining work

- Build distance-based LODs and stream terrain chunks instead of keeping every source mesh resident.
- Add simplified collision proxies and blend chunk borders.
- Inspect MTL material import and terrain appearance in the Android build.
- Profile frame rate and memory on the target Android device before increasing scene detail.
- Headless CI does not replace visual review or a physical Android performance test.


## Godot OBJ importer surface-limit correction

The source meshes originally changed `usemtl` many times across neighbouring faces. Godot's OBJ importer treated these material changes as new mesh surfaces and emitted `MAX_MESH_SURFACES` errors during headless import. The face geometry and vertex data are unchanged; each OBJ now groups its faces into one contiguous block per material, keeping each mesh at one to four surfaces. The shared MTL library declares the crop material used by the farm tile.

`tools/audit_obj_material_groups.py` checks all 23 files, face/vertex counts, shared material declarations and contiguous material blocks. Both Godot validation and Android export run this audit before importing resources.
