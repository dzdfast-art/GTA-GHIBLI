# GTA GHIBLI — High-detail terrain integration

This change connects four already-tracked original OBJ terrain assets to the four district blockouts created by `open_world_regions.gd`.

| District | Source tile | Source profile |
|---|---|---|
| Harbor City | `harbor_flats_112.obj` | Low-relief harbor ground with soil and water-edge material groups |
| Pine Highlands | `pine_forest_floor_112.obj` | Forest floor with gentle terrain variation |
| Amber Valley | `meadow_basin_112.obj` | Meadow basin terrain |
| Sapphire Coast | `coastal_grass_112.obj` | Coastal grass terrain |

Each tile is imported at a mobile-conscious visual scale and added to the district as a terrain backdrop. The existing flat district pad remains in place as a simple playable surface and collision-free blockout; the terrain backdrops do not replace the ground collision or claim to be final collision terrain.

The loader supports both common Godot OBJ import resource forms: a `PackedScene` or a `Mesh`. The test suite verifies that all four districts receive a terrain node and that the loader reports four successful terrain resources.

## Remaining work

- Add distance-based terrain LOD and streaming before expanding the number of visible chunks.
- Create simplified collision proxies where terrain becomes walkable.
- Review material import results and framing in the Android build.
- Perform a physical Android visual/performance test; headless CI cannot establish this.
