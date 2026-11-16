# Regional terrain expansion

This phase adds 57 original OBJ source tiles (approximately 143.9 MB) to the project.
Four district-specific tiles are attached at runtime: Harbor City, Pine Highlands,
Amber Valley, and Sapphire Coast. The remaining source meshes are retained as a
catalog for later streaming and region expansion.

The OBJ surface-budget validator scans every OBJ under assets before import.
The runtime loader supports both Mesh and PackedScene importer outputs and the
CI regression test verifies that each district receives a non-empty mesh.

This is a visual terrain-source milestone, not a finished terrain system:
collision proxies, seamless edge blending, distance-based LOD/streaming, and
on-device Android frame-time/memory profiling remain required before release.
