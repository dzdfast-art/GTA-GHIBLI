extends Node

## Adds district terrain visuals and static collision to the four world regions.
## Terrain collision is generated from the imported mesh; LOD and edge blending remain follow-up work.
const DISTRICT_TILES := {
	"HarborCity": preload("res://assets/environment/terrain/expansion_150mb/harbor_rail_yards.obj"),
	"PineHighlands": preload("res://assets/environment/terrain/expansion_150mb/pine_cedar_ridge.obj"),
	"AmberValley": preload("res://assets/environment/terrain/expansion_150mb/amber_orchard_slope.obj"),
	"SapphireCoast": preload("res://assets/environment/terrain/expansion_150mb/sapphire_tidal_shelf.obj")
}

var _attached_count := 0
var _collision_count := 0

func _ready() -> void:
	var regions := get_parent().get_node_or_null("OpenWorldRegions")
	if regions == null:
		push_warning("Terrain expansion: OpenWorldRegions node was not found.")
		return
	for district_name in DISTRICT_TILES:
		var district := regions.get_node_or_null(district_name) as Node3D
		if district == null:
			push_warning("Terrain expansion: missing district " + district_name)
			continue
		var terrain_mesh := _extract_mesh(DISTRICT_TILES[district_name] as Resource)
		if terrain_mesh == null:
			push_error("Terrain expansion: could not load mesh for " + district_name)
			continue

		var tile := MeshInstance3D.new()
		tile.name = "ExpansionTerrain_" + district_name
		tile.mesh = terrain_mesh
		tile.position = Vector3(0.0, 0.08, 0.0)
		tile.scale = Vector3(0.18, 0.10, 0.18)
		tile.visibility_range_end = 220.0
		tile.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		tile.add_to_group("world_terrain_chunks")
		district.add_child(tile)
		_attached_count += 1

		var collision_shape := terrain_mesh.create_trimesh_shape()
		if collision_shape == null:
			push_warning("Terrain expansion: collision generation failed for " + district_name)
			continue
		var collision_body := StaticBody3D.new()
		collision_body.name = "ExpansionTerrainCollision_" + district_name
		collision_body.position = tile.position
		collision_body.scale = tile.scale
		collision_body.collision_layer = 1
		collision_body.collision_mask = 1
		var collision := CollisionShape3D.new()
		collision.name = "TerrainCollisionShape"
		collision.shape = collision_shape
		collision_body.add_child(collision)
		district.add_child(collision_body)
		_collision_count += 1

func _extract_mesh(source: Resource) -> Mesh:
	if source is Mesh:
		return source as Mesh
	if source is PackedScene:
		var instance := (source as PackedScene).instantiate()
		var mesh_instance := instance as MeshInstance3D
		if mesh_instance == null:
			var candidates := instance.find_children("*", "MeshInstance3D", true, false)
			if not candidates.is_empty():
				mesh_instance = candidates[0] as MeshInstance3D
		var result: Mesh
		if mesh_instance != null and mesh_instance.mesh != null:
			result = mesh_instance.mesh.duplicate() as Mesh
		instance.free()
		return result
	return null

func get_attached_count() -> int:
	return _attached_count

func get_collision_count() -> int:
	return _collision_count
