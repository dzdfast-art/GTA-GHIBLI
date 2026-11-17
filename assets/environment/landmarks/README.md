# Coastal landmarks

## Coastal Fortress Landmark

Original modular low-poly fortress source mesh for GTA GHIBLI's Sapphire Coast / Harbor City transition.

Includes layered curtain walls, arched gate opening, four corner watchtowers, crenellated crowns, gatehouse stones, iron portcullis bars, timber gate panels, courtyard paving, interior barracks blocks and parapet modules.

## Sapphire Coast Fishing Boat

Original low-poly fishing boat for the playable Sapphire Coast harbour. The mesh includes a deep-V hull, deck, cabin, glazing, mast, net rack, crates, rope drums, buoys and simplified deck equipment.

- Source: `sapphire_fishing_boat.obj` with `sapphire_fishing_boat.mtl`.
- Runtime scene: `res://scenes/world/sapphire_fishing_boat.tscn`.
- Integrated by `scripts/world/open_world_regions.gd` at the Sapphire Coast water area.
- The scene uses one imported visual mesh and one simplified `AnimatableBody3D` hull collider.
- `scripts/world/fishing_boat_idle.gd` supplies subtle bobbing and roll for the harbour water.

## Import notes

- OBJ coordinates are in metres; ground level is approximately Y=0.
- The fortress source asset remains a source mesh and is not yet placed in a playable scene.
- The fishing boat is integrated into the playable Sapphire Coast district and covered by a Godot import/integration test.
- Keep visible detail meshes separate from simplified collision meshes when integrating new landmarks.
- Both landmark meshes are original GTA GHIBLI assets; no third-party game assets are included.
