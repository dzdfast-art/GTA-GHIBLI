extends Node

## Streams seventy-six original terrain tiles into the four open-world districts.
## High-detail source tiles join the proximity catalog and receive matching static collision.
const TERRAIN_TILES := [
	{"district": "HarborCity", "tile": "harbor_rail_yards", "path": "res://assets/environment/terrain/expansion_150mb/harbor_rail_yards.obj", "offset": Vector3.ZERO},
	{"district": "HarborCity", "tile": "harbor_tidal_marsh", "path": "res://assets/environment/terrain/expansion_300mb/harbor_tidal_marsh.obj", "offset": Vector3(28.0, 0.0, 0.0)},
	{"district": "HarborCity", "tile": "harbor_container_flats", "path": "res://assets/environment/terrain/expansion_300mb/harbor_container_flats.obj", "offset": Vector3(0.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "pine_cedar_ridge", "path": "res://assets/environment/terrain/expansion_150mb/pine_cedar_ridge.obj", "offset": Vector3.ZERO},
	{"district": "PineHighlands", "tile": "pine_misty_bowl", "path": "res://assets/environment/terrain/expansion_300mb/pine_misty_bowl.obj", "offset": Vector3(28.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "pine_needle_ridge", "path": "res://assets/environment/terrain/expansion_300mb/pine_needle_ridge.obj", "offset": Vector3(0.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "amber_orchard_slope", "path": "res://assets/environment/terrain/expansion_150mb/amber_orchard_slope.obj", "offset": Vector3.ZERO},
	{"district": "AmberValley", "tile": "amber_rolling_fields", "path": "res://assets/environment/terrain/expansion_300mb/amber_rolling_fields.obj", "offset": Vector3(28.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "amber_orchard_steps", "path": "res://assets/environment/terrain/expansion_300mb/amber_orchard_steps.obj", "offset": Vector3(0.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "sapphire_tidal_shelf", "path": "res://assets/environment/terrain/expansion_150mb/sapphire_tidal_shelf.obj", "offset": Vector3.ZERO},
	{"district": "SapphireCoast", "tile": "sapphire_sea_cliffs", "path": "res://assets/environment/terrain/expansion_300mb/sapphire_sea_cliffs.obj", "offset": Vector3(28.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "sapphire_coral_shelf", "path": "res://assets/environment/terrain/expansion_300mb/sapphire_coral_shelf.obj", "offset": Vector3(0.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "harbor_floodplain_west", "path": "res://assets/environment/terrain/expansion_150mb/harbor_floodplain_west.obj", "offset": Vector3(56.0, 0.0, 0.0)},
	{"district": "HarborCity", "tile": "harbor_old_quarry", "path": "res://assets/environment/terrain/expansion_150mb/harbor_old_quarry.obj", "offset": Vector3(84.0, 0.0, 0.0)},
	{"district": "HarborCity", "tile": "harbor_outer_marsh", "path": "res://assets/environment/terrain/expansion_150mb/harbor_outer_marsh.obj", "offset": Vector3(28.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "harbor_rail_flats", "path": "res://assets/environment/terrain/expansion_150mb/harbor_rail_flats.obj", "offset": Vector3(56.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "urban_canal_banks", "path": "res://assets/environment/terrain/expansion_150mb/urban_canal_banks.obj", "offset": Vector3(84.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "highland_switchbacks", "path": "res://assets/environment/terrain/expansion_150mb/highland_switchbacks.obj", "offset": Vector3(56.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "northern_forest_bowl", "path": "res://assets/environment/terrain/expansion_150mb/northern_forest_bowl.obj", "offset": Vector3(84.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "pine_fog_valley", "path": "res://assets/environment/terrain/expansion_150mb/pine_fog_valley.obj", "offset": Vector3(28.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "pine_forest_bowl", "path": "res://assets/environment/terrain/expansion_150mb/pine_forest_bowl.obj", "offset": Vector3(56.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "pine_needle_uplands", "path": "res://assets/environment/terrain/expansion_150mb/pine_needle_uplands.obj", "offset": Vector3(84.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "amber_river_meanders", "path": "res://assets/environment/terrain/expansion_150mb/amber_river_meanders.obj", "offset": Vector3(56.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "amber_valley_terraces", "path": "res://assets/environment/terrain/expansion_150mb/amber_valley_terraces.obj", "offset": Vector3(84.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "amber_wheat_basin", "path": "res://assets/environment/terrain/expansion_150mb/amber_wheat_basin.obj", "offset": Vector3(28.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "farm_irrigation_fields", "path": "res://assets/environment/terrain/expansion_150mb/farm_irrigation_fields.obj", "offset": Vector3(56.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "farmstead_lowlands", "path": "res://assets/environment/terrain/expansion_150mb/farmstead_lowlands.obj", "offset": Vector3(84.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "basalt_coast_shelves", "path": "res://assets/environment/terrain/expansion_150mb/basalt_coast_shelves.obj", "offset": Vector3(56.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "coastal_bluff_west", "path": "res://assets/environment/terrain/expansion_150mb/coastal_bluff_west.obj", "offset": Vector3(84.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "sapphire_headland_east", "path": "res://assets/environment/terrain/expansion_150mb/sapphire_headland_east.obj", "offset": Vector3(28.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "sapphire_tidal_flats", "path": "res://assets/environment/terrain/expansion_150mb/sapphire_tidal_flats.obj", "offset": Vector3(56.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "sapphire_wind_cliffs", "path": "res://assets/environment/terrain/expansion_150mb/sapphire_wind_cliffs.obj", "offset": Vector3(84.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "harbor_dredge_basin", "path": "res://assets/environment/terrain/expansion_300mb/harbor_dredge_basin.obj", "offset": Vector3(112.0, 0.0, 0.0)},
	{"district": "HarborCity", "tile": "heron_marsh_backwater", "path": "res://assets/environment/terrain/expansion_300mb/heron_marsh_backwater.obj", "offset": Vector3(140.0, 0.0, 0.0)},
	{"district": "HarborCity", "tile": "saltmarsh_lagoon_east", "path": "res://assets/environment/terrain/expansion_300mb/saltmarsh_lagoon_east.obj", "offset": Vector3(168.0, 0.0, 0.0)},
	{"district": "HarborCity", "tile": "riverstone_delta_bars", "path": "res://assets/environment/terrain/expansion_300mb/riverstone_delta_bars.obj", "offset": Vector3(196.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "pine_stone_pass", "path": "res://assets/environment/terrain/expansion_300mb/pine_stone_pass.obj", "offset": Vector3(112.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "pine_stone_ridge", "path": "res://assets/environment/terrain/expansion_300mb/pine_stone_ridge.obj", "offset": Vector3(140.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "cedar_cloud_summit", "path": "res://assets/environment/terrain/expansion_300mb/cedar_cloud_summit.obj", "offset": Vector3(168.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "windward_pine_escarpment", "path": "res://assets/environment/terrain/expansion_300mb/windward_pine_escarpment.obj", "offset": Vector3(196.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "amber_dry_wash", "path": "res://assets/environment/terrain/expansion_300mb/amber_dry_wash.obj", "offset": Vector3(112.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "copper_badlands_ridge", "path": "res://assets/environment/terrain/expansion_300mb/copper_badlands_ridge.obj", "offset": Vector3(140.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "mesa_terrace_south", "path": "res://assets/environment/terrain/expansion_300mb/mesa_terrace_south.obj", "offset": Vector3(168.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "ochre_dry_wash", "path": "res://assets/environment/terrain/expansion_300mb/ochre_dry_wash.obj", "offset": Vector3(196.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "sapphire_salt_lagoon", "path": "res://assets/environment/terrain/expansion_300mb/sapphire_salt_lagoon.obj", "offset": Vector3(112.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "sapphire_tidal_bench", "path": "res://assets/environment/terrain/expansion_300mb/sapphire_tidal_bench.obj", "offset": Vector3(140.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "sapphire_tidepools_north", "path": "res://assets/environment/terrain/expansion_300mb/sapphire_tidepools_north.obj", "offset": Vector3(168.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "coral_shelf_headland", "path": "res://assets/environment/terrain/expansion_300mb/coral_shelf_headland.obj", "offset": Vector3(196.0, 0.0, 0.0)},
	{"district": "HarborCity", "tile": "marsh_channel_west", "path": "res://assets/environment/terrain/expansion_150mb/marsh_channel_west.obj", "offset": Vector3(112.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "willow_marsh_islands", "path": "res://assets/environment/terrain/expansion_150mb/willow_marsh_islands.obj", "offset": Vector3(140.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "river_delta_east", "path": "res://assets/environment/terrain/expansion_150mb/river_delta_east.obj", "offset": Vector3(168.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "wetland_reed_plain", "path": "res://assets/environment/terrain/expansion_150mb/wetland_reed_plain.obj", "offset": Vector3(196.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "lake_mirror_basin", "path": "res://assets/environment/terrain/expansion_150mb/lake_mirror_basin.obj", "offset": Vector3(224.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "willow_village_outer_hills", "path": "res://assets/environment/terrain/expansion_150mb/willow_village_outer_hills.obj", "offset": Vector3(252.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "cedar_plateau_west", "path": "res://assets/environment/terrain/expansion_150mb/cedar_plateau_west.obj", "offset": Vector3(112.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "granite_crown_east", "path": "res://assets/environment/terrain/expansion_150mb/granite_crown_east.obj", "offset": Vector3(140.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "granite_foothill_east", "path": "res://assets/environment/terrain/expansion_150mb/granite_foothill_east.obj", "offset": Vector3(168.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "granite_ravine_west", "path": "res://assets/environment/terrain/expansion_150mb/granite_ravine_west.obj", "offset": Vector3(196.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "granite_ridge_summit", "path": "res://assets/environment/terrain/expansion_150mb/granite_ridge_summit.obj", "offset": Vector3(224.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "mountain_pass_upper", "path": "res://assets/environment/terrain/expansion_150mb/mountain_pass_upper.obj", "offset": Vector3(252.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "desert_mesa_fields", "path": "res://assets/environment/terrain/expansion_150mb/desert_mesa_fields.obj", "offset": Vector3(112.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "desert_wash_plateau", "path": "res://assets/environment/terrain/expansion_150mb/desert_wash_plateau.obj", "offset": Vector3(140.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "orchard_copse_hills", "path": "res://assets/environment/terrain/expansion_150mb/orchard_copse_hills.obj", "offset": Vector3(168.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "orchard_ridge_south", "path": "res://assets/environment/terrain/expansion_150mb/orchard_ridge_south.obj", "offset": Vector3(196.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "orchard_terraces_north", "path": "res://assets/environment/terrain/expansion_150mb/orchard_terraces_north.obj", "offset": Vector3(224.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "red_canyon_rim_north", "path": "res://assets/environment/terrain/expansion_150mb/red_canyon_rim_north.obj", "offset": Vector3(252.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "basalt_coastal_spur", "path": "res://assets/environment/terrain/expansion_150mb/basalt_coastal_spur.obj", "offset": Vector3(112.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "sapphire_coast_rock_shelf", "path": "res://assets/environment/terrain/expansion_150mb/sapphire_coast_rock_shelf.obj", "offset": Vector3(140.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "sapphire_wind_headland", "path": "res://assets/environment/terrain/expansion_300mb/sapphire_wind_headland.obj", "offset": Vector3(168.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "seagrass_coastal_plain", "path": "res://assets/environment/terrain/expansion_300mb/seagrass_coastal_plain.obj", "offset": Vector3(196.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "whitecliff_staircase", "path": "res://assets/environment/terrain/expansion_300mb/whitecliff_staircase.obj", "offset": Vector3(224.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "red_bridge_ravine_east", "path": "res://assets/environment/terrain/expansion_300mb/red_bridge_ravine_east.obj", "offset": Vector3(252.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "harbor_breakwater_112", "path": "res://assets/environment/terrain/high_detail/harbor_breakwater_112.obj", "offset": Vector3(280.0, 0.0, 0.0) , "scale": Vector3(0.126, 0.10, 0.126)},
	{"district": "PineHighlands", "tile": "pine_granite_spur_112", "path": "res://assets/environment/terrain/high_detail/pine_granite_spur_112.obj", "offset": Vector3(280.0, 0.0, 0.0) , "scale": Vector3(0.126, 0.10, 0.126)},
	{"district": "AmberValley", "tile": "amber_vineyard_terraces_112", "path": "res://assets/environment/terrain/high_detail/amber_vineyard_terraces_112.obj", "offset": Vector3(280.0, 0.0, 0.0) , "scale": Vector3(0.126, 0.10, 0.126)},
	{"district": "SapphireCoast", "tile": "sapphire_tidepool_rim_112", "path": "res://assets/environment/terrain/high_detail/sapphire_tidepool_rim_112.obj", "offset": Vector3(280.0, 0.0, 0.0) , "scale": Vector3(0.126, 0.10, 0.126)},
]
 
const LOAD_RADIUS := 72.0
const UNLOAD_RADIUS := 96.0
const MAX_ACTIVE_TILES := 6
const MAX_LOADS_PER_REFRESH := 2
const STREAM_UPDATE_INTERVAL := 0.35

var _regions_root: Node3D
var _districts: Dictionary = {}
var _active_tiles: Dictionary = {}
var _refresh_elapsed := 0.0


func _ready() -> void:
	var parent := get_parent()
	if parent == null:
		push_warning("Terrain streaming: parent world was not found.")
		return
	_regions_root = parent.get_node_or_null("OpenWorldRegions") as Node3D
	if _regions_root == null:
		push_warning("Terrain streaming: OpenWorldRegions node was not found.")
		return
	for district in _regions_root.get_children():
		if district is Node3D:
			_districts[district.name] = district
	var missing := get_missing_resource_paths()
	if not missing.is_empty():
		push_warning("Terrain streaming: missing terrain resources: " + ", ".join(missing))


func _process(delta: float) -> void:
	_refresh_elapsed += maxf(0.0, delta)
	if _refresh_elapsed < STREAM_UPDATE_INTERVAL:
		return
	_refresh_elapsed = 0.0
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		_unload_all_tiles()
		return
	var player := players[0] as Node3D
	if player != null:
		refresh_for_player(player)


## Public entry point used by the runtime and deterministic regression tests.
func refresh_for_player(player: Node3D) -> void:
	if player == null or not is_instance_valid(player) or _regions_root == null:
		return

	var candidates: Array[Dictionary] = []
	for tile_data in TERRAIN_TILES:
		var tile_name := str(tile_data.get("tile", ""))
		var district_name := str(tile_data.get("district", ""))
		var district := _districts.get(district_name) as Node3D
		if district == null:
			continue
		var local_offset: Vector3 = tile_data.get("offset", Vector3.ZERO)
		var world_position := district.to_global(local_offset + Vector3(0.0, 0.08, 0.0))
		var distance := player.global_position.distance_to(world_position)

		if _active_tiles.has(tile_name):
			if distance > UNLOAD_RADIUS:
				_unload_tile(tile_name)
			continue
		if distance <= LOAD_RADIUS:
			candidates.append({
				"data": tile_data,
				"district": district,
				"distance": distance
			})

	candidates.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return float(left["distance"]) < float(right["distance"])
	)
	var loads_remaining := MAX_LOADS_PER_REFRESH
	for candidate in candidates:
		if loads_remaining <= 0 or _active_tiles.size() >= MAX_ACTIVE_TILES:
			break
		var tile_data: Dictionary = candidate["data"]
		var tile_name := str(tile_data.get("tile", ""))
		if _active_tiles.has(tile_name):
			continue
		if _load_tile(candidate["district"] as Node3D, tile_data):
			loads_remaining -= 1


func _load_tile(district: Node3D, tile_data: Dictionary) -> bool:
	var tile_name := str(tile_data.get("tile", ""))
	var resource_path := str(tile_data.get("path", ""))
	if resource_path.is_empty() or not ResourceLoader.exists(resource_path):
		push_error("Terrain streaming: resource does not exist: " + resource_path)
		return false
	var source := ResourceLoader.load(resource_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if source == null:
		push_error("Terrain streaming: failed to load " + resource_path)
		return false
	var terrain_mesh := _extract_mesh(source)
	if terrain_mesh == null:
		push_error("Terrain streaming: could not extract mesh " + tile_name)
		return false

	var tile := MeshInstance3D.new()
	tile.name = "ExpansionTerrain_" + tile_name
	tile.mesh = terrain_mesh
	tile.position = tile_data.get("offset", Vector3.ZERO) + Vector3(0.0, 0.08, 0.0)
	tile.scale = tile_data.get("scale", Vector3(0.18, 0.10, 0.18))
	tile.visibility_range_end = 420.0
	tile.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	tile.add_to_group("world_terrain_chunks")

	var collision_shape := terrain_mesh.create_trimesh_shape()
	if collision_shape == null:
		push_error("Terrain streaming: collision generation failed for " + tile_name)
		return false
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

	district.add_child(tile)
	district.add_child(collision_body)
	_active_tiles[tile_name] = {
		"visual": tile,
		"collision": collision_body
	}
	return true


func _unload_tile(tile_name: String) -> void:
	if not _active_tiles.has(tile_name):
		return
	var record: Dictionary = _active_tiles[tile_name]
	var visual := record.get("visual") as Node
	var collision := record.get("collision") as Node
	if is_instance_valid(visual):
		visual.queue_free()
	if is_instance_valid(collision):
		collision.queue_free()
	_active_tiles.erase(tile_name)


func _unload_all_tiles() -> void:
	for tile_name in _active_tiles.keys().duplicate():
		_unload_tile(str(tile_name))


func _extract_mesh(source: Resource) -> Mesh:
	if source is Mesh:
		return (source as Mesh).duplicate() as Mesh
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


func get_catalog_count() -> int:
	return TERRAIN_TILES.size()


func get_attached_count() -> int:
	return _active_tiles.size()


func get_collision_count() -> int:
	var count := 0
	for record in _active_tiles.values():
		if is_instance_valid(record.get("collision") as Node):
			count += 1
	return count


func get_active_tile_names() -> Array[String]:
	var names: Array[String] = []
	for tile_name in _active_tiles.keys():
		names.append(str(tile_name))
	names.sort()
	return names


func get_missing_resource_paths() -> Array[String]:
	var missing: Array[String] = []
	for tile_data in TERRAIN_TILES:
		var resource_path := str(tile_data.get("path", ""))
		if not ResourceLoader.exists(resource_path):
			missing.append(resource_path)
	return missing
