# GTA GHIBLI — Regional Terrain Expansion

This optional expansion contains 57 original OBJ elevation-surface meshes for additional regions and traversal spaces.

## Included regions

The source tiles cover orchard slopes and farm basins, river meanders, basalt and sapphire coastlines, cedar and pine highlands, harbor floodplains and rail yards, red-canyon shelves, marsh islands, mountain passes, and the outer hills around Willow Village.

## Technical notes

- These are source terrain meshes, not baked Android LODs.
- Keep them out of the active mobile scene until their import cost, collision simplification, LODs, and streaming boundaries are validated.
- Do not instantiate all 57 meshes at once on Android.
- The red-bridge ravine tile is terrain around the landmark; it is not itself a completed bridge model.
- The bicycle and house portal in this branch are gameplay prototypes and require regression testing before merge.

## Integration status

The terrain pack is staged in this branch only. It is not yet connected to the playable world in `main`.
