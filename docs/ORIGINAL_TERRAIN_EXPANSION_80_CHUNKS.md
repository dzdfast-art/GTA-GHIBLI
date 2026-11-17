# Original Terrain Expansion — 80 Chunks

## Included terrain
This addition contributes eight distinct, mobile-scale terrain meshes to the four open-world regions:

- Harbor City: estuary banks and mangrove flats.
- Pine Highlands: snowline ridge and mist basin.
- Amber Valley: red canyon and wheat terraces.
- Sapphire Coast: tidepool cliffs and coral ridge.

Each OBJ is a real triangulated height-field mesh with its own grid resolution, UV coordinates, a named object, and a region-specific MTL material. The meshes are not empty padding files: they are preloaded by the terrain expansion runtime and receive static collision bodies.

## Runtime and validation
The world terrain runtime now registers 80 terrain chunks. The regression test verifies that every expected chunk loads into its named district and has a generated mesh and static collision shape.

CI also runs `tools/validate_obj_surface_counts.py` to enforce the imported OBJ surface budget.

## Validation commands
`godot --headless --editor --path . --quit`
`godot --headless --path . --script res://tests/terrain_expansion_runtime_test.gd`
