extends Node

## Streams twelve original terrain tiles into the four open-world districts.
## Each district receives a main tile and two adjacent expansion tiles with static collision.
const TERRAIN_TILES := [
	{"district": "HarborCity", "tile": "harbor_rail_yards", "resource": preload("res://assets/environment/terrain/expansion_150mb/harbor_rail_yards.obj"), "offset": Vector3.ZERO},
	{"district": "HarborCity", "tile": "harbor_tidal_marsh", "resource": preload("res://assets/environment/terrain/expansion_300mb/harbor_tidal_marsh.obj"), "offset": Vector3(28.0, 0.0, 0.0)},
	{"district": "HarborCity", "tile": "harbor_container_flats", "resource": preload("res://assets/environment/terrain/expansion_300mb/harbor_container_flats.obj"), "offset": Vector3(0.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "pine_cedar_ridge", "resource": preload("res://assets/environment/terrain/expansion_150mb/pine_cedar_ridge.obj"), "offset": Vector3.ZERO},
	{"district": "PineHighlands", "tile": "pine_misty_bowl", "resource": preload("res://assets/environment/terrain/expansion_300mb/pine_misty_bowl.obj"), "offset": Vector3(28.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "pine_needle_ridge", "resource": preload("res://assets/environment/terrain/expansion_300mb/pine_needle_ridge.obj"), "offset": Vector3(0.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "amber_orchard_slope", "resource": preload("res://assets/environment/terrain/expansion_150mb/amber_orchard_slope.obj"), "offset": Vector3.ZERO},
	{"district": "AmberValley", "tile": "amber_rolling_fields", "resource": preload("res://assets/environment/terrain/expansion_300mb/amber_rolling_fields.obj"), "offset": Vector3(28.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "amber_orchard_steps", "resource": preload("res://assets/environment/terrain/expansion_300mb/amber_orchard_steps.obj"), "offset": Vector3(0.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "sapphire_tidal_shelf", "resource": preload("res://assets/environment/terrain/expansion_150mb/sapphire_tidal_shelf.obj"), "offset": Vector3.ZERO},
	{"district": "SapphireCoast", "tile": "sapphire_sea_cliffs", "resource": preload("res://assets/environment/terrain/expansion_300mb/sapphire_sea_cliffs.obj"), "offset": Vector3(28.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "sapphire_coral_shelf", "resource": preload("res://assets/environment/terrain/expansion_300mb/sapphire_coral_shelf.obj"), "offset": Vector3(0.0, 0.0, 28.0)}
]

var _attached_count := 0
var _collision_count := 0

func _ready() -> void:
	var regions := get_parent().get_node_or_null("OpenWorldRegions")
	if regions == null:
		push_warning("Terrain expansion: OpenWorldRegions node was not found.")
		return

	for tile_data in TERRAIN_TILES:
		var district_name: String = tile_data["district"]
		var district := regions.get_node_or_null(district_name) as Node3D
		if district == null:
			push_warning("Terrain expansion: missing district " + district_name)
			continue
		var tile_name: String = tile_data["tile"]
		_attach_tile(district, tile_name, tile_data["resource"], tile_data["offset"])

func _attach_tile(district: Node3D, tile_name: String, source: Resource, offset: Vector3) -> void:
	var terrain_mesh := _extract_mesh(source)
	if terrain_mesh == null:
		push_error("Terrain expansion: could not load mesh " + tile_name)
		return

	var tile := MeshInstance3D.new()
	tile.name = "ExpansionTerrain_" + tile_name
	tile.mesh = terrain_mesh
	tile.position = offset + Vector3(0.0, 0.08, 0.0)
	tile.scale = Vector3(0.18, 0.10, 0.18)
	tile.visibility_range_end = 220.0
	tile.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	tile.add_to_group("world_terrain_chunks")
	district.add_child(tile)
	_attached_count += 1

	var collision_shape := terrain_mesh.create_trimesh_shape()
	if collision_shape == null:
		push_warning("Terrain expansion: collision generation failed for " + tile_name)
		return
	var collision_body := StaticBody3D.new()
	collision_body.name = "ExpansionTerrainCollision_" + tile_name
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
