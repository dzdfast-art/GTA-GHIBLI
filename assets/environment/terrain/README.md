# Terrain mesh tiles

Four original 96 x 96 vertex-grid OBJ terrain tiles for Godot 4 environment prototyping. Each tile spans 190 x 190 world units at 2-unit vertex spacing. Faces are triangulated; material groups provide simple biome color variation.

- `pine_highlands_tile.obj`: rolling forest hills with higher rocky ridges.
- `sapphire_coast_dunes_tile.obj`: low coastal dunes and dry-grass/sand bands.
- `amber_valley_tile.obj`: gentle agricultural valley terrain.
- `willow_riverbank_tile.obj`: flatter riverbank terrain with damp patches.

Import the OBJ files in Godot 4, inspect normals/material groups, then place and blend tiles in world scenes. These are terrain source meshes and are not yet connected to the playable world. For Android, use lower LOD variants or Godot mesh simplification before deploying large areas.
