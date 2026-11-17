extends Node

## Streams eighty original terrain tiles into the four open-world districts.
## Each district receives twelve adjacent terrain tiles with static collision.
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
	{"district": "SapphireCoast", "tile": "sapphire_coral_shelf", "resource": preload("res://assets/environment/terrain/expansion_300mb/sapphire_coral_shelf.obj"), "offset": Vector3(0.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "harbor_floodplain_west", "resource": preload("res://assets/environment/terrain/expansion_150mb/harbor_floodplain_west.obj"), "offset": Vector3(56.0, 0.0, 0.0)},
	{"district": "HarborCity", "tile": "harbor_old_quarry", "resource": preload("res://assets/environment/terrain/expansion_150mb/harbor_old_quarry.obj"), "offset": Vector3(84.0, 0.0, 0.0)},
	{"district": "HarborCity", "tile": "harbor_outer_marsh", "resource": preload("res://assets/environment/terrain/expansion_150mb/harbor_outer_marsh.obj"), "offset": Vector3(28.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "harbor_rail_flats", "resource": preload("res://assets/environment/terrain/expansion_150mb/harbor_rail_flats.obj"), "offset": Vector3(56.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "urban_canal_banks", "resource": preload("res://assets/environment/terrain/expansion_150mb/urban_canal_banks.obj"), "offset": Vector3(84.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "highland_switchbacks", "resource": preload("res://assets/environment/terrain/expansion_150mb/highland_switchbacks.obj"), "offset": Vector3(56.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "northern_forest_bowl", "resource": preload("res://assets/environment/terrain/expansion_150mb/northern_forest_bowl.obj"), "offset": Vector3(84.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "pine_fog_valley", "resource": preload("res://assets/environment/terrain/expansion_150mb/pine_fog_valley.obj"), "offset": Vector3(28.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "pine_forest_bowl", "resource": preload("res://assets/environment/terrain/expansion_150mb/pine_forest_bowl.obj"), "offset": Vector3(56.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "pine_needle_uplands", "resource": preload("res://assets/environment/terrain/expansion_150mb/pine_needle_uplands.obj"), "offset": Vector3(84.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "amber_river_meanders", "resource": preload("res://assets/environment/terrain/expansion_150mb/amber_river_meanders.obj"), "offset": Vector3(56.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "amber_valley_terraces", "resource": preload("res://assets/environment/terrain/expansion_150mb/amber_valley_terraces.obj"), "offset": Vector3(84.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "amber_wheat_basin", "resource": preload("res://assets/environment/terrain/expansion_150mb/amber_wheat_basin.obj"), "offset": Vector3(28.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "farm_irrigation_fields", "resource": preload("res://assets/environment/terrain/expansion_150mb/farm_irrigation_fields.obj"), "offset": Vector3(56.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "farmstead_lowlands", "resource": preload("res://assets/environment/terrain/expansion_150mb/farmstead_lowlands.obj"), "offset": Vector3(84.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "basalt_coast_shelves", "resource": preload("res://assets/environment/terrain/expansion_150mb/basalt_coast_shelves.obj"), "offset": Vector3(56.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "coastal_bluff_west", "resource": preload("res://assets/environment/terrain/expansion_150mb/coastal_bluff_west.obj"), "offset": Vector3(84.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "sapphire_headland_east", "resource": preload("res://assets/environment/terrain/expansion_150mb/sapphire_headland_east.obj"), "offset": Vector3(28.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "sapphire_tidal_flats", "resource": preload("res://assets/environment/terrain/expansion_150mb/sapphire_tidal_flats.obj"), "offset": Vector3(56.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "sapphire_wind_cliffs", "resource": preload("res://assets/environment/terrain/expansion_150mb/sapphire_wind_cliffs.obj"), "offset": Vector3(84.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "harbor_dredge_basin", "resource": preload("res://assets/environment/terrain/expansion_300mb/harbor_dredge_basin.obj"), "offset": Vector3(112.0, 0.0, 0.0)},
	{"district": "HarborCity", "tile": "heron_marsh_backwater", "resource": preload("res://assets/environment/terrain/expansion_300mb/heron_marsh_backwater.obj"), "offset": Vector3(140.0, 0.0, 0.0)},
	{"district": "HarborCity", "tile": "saltmarsh_lagoon_east", "resource": preload("res://assets/environment/terrain/expansion_300mb/saltmarsh_lagoon_east.obj"), "offset": Vector3(168.0, 0.0, 0.0)},
	{"district": "HarborCity", "tile": "riverstone_delta_bars", "resource": preload("res://assets/environment/terrain/expansion_300mb/riverstone_delta_bars.obj"), "offset": Vector3(196.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "pine_stone_pass", "resource": preload("res://assets/environment/terrain/expansion_300mb/pine_stone_pass.obj"), "offset": Vector3(112.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "pine_stone_ridge", "resource": preload("res://assets/environment/terrain/expansion_300mb/pine_stone_ridge.obj"), "offset": Vector3(140.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "cedar_cloud_summit", "resource": preload("res://assets/environment/terrain/expansion_300mb/cedar_cloud_summit.obj"), "offset": Vector3(168.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "windward_pine_escarpment", "resource": preload("res://assets/environment/terrain/expansion_300mb/windward_pine_escarpment.obj"), "offset": Vector3(196.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "amber_dry_wash", "resource": preload("res://assets/environment/terrain/expansion_300mb/amber_dry_wash.obj"), "offset": Vector3(112.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "copper_badlands_ridge", "resource": preload("res://assets/environment/terrain/expansion_300mb/copper_badlands_ridge.obj"), "offset": Vector3(140.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "mesa_terrace_south", "resource": preload("res://assets/environment/terrain/expansion_300mb/mesa_terrace_south.obj"), "offset": Vector3(168.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "ochre_dry_wash", "resource": preload("res://assets/environment/terrain/expansion_300mb/ochre_dry_wash.obj"), "offset": Vector3(196.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "sapphire_salt_lagoon", "resource": preload("res://assets/environment/terrain/expansion_300mb/sapphire_salt_lagoon.obj"), "offset": Vector3(112.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "sapphire_tidal_bench", "resource": preload("res://assets/environment/terrain/expansion_300mb/sapphire_tidal_bench.obj"), "offset": Vector3(140.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "sapphire_tidepools_north", "resource": preload("res://assets/environment/terrain/expansion_300mb/sapphire_tidepools_north.obj"), "offset": Vector3(168.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "coral_shelf_headland", "resource": preload("res://assets/environment/terrain/expansion_300mb/coral_shelf_headland.obj"), "offset": Vector3(196.0, 0.0, 0.0)},
	{"district": "HarborCity", "tile": "marsh_channel_west", "resource": preload("res://assets/environment/terrain/expansion_150mb/marsh_channel_west.obj"), "offset": Vector3(112.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "willow_marsh_islands", "resource": preload("res://assets/environment/terrain/expansion_150mb/willow_marsh_islands.obj"), "offset": Vector3(140.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "river_delta_east", "resource": preload("res://assets/environment/terrain/expansion_150mb/river_delta_east.obj"), "offset": Vector3(168.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "wetland_reed_plain", "resource": preload("res://assets/environment/terrain/expansion_150mb/wetland_reed_plain.obj"), "offset": Vector3(196.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "lake_mirror_basin", "resource": preload("res://assets/environment/terrain/expansion_150mb/lake_mirror_basin.obj"), "offset": Vector3(224.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "willow_village_outer_hills", "resource": preload("res://assets/environment/terrain/expansion_150mb/willow_village_outer_hills.obj"), "offset": Vector3(252.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "cedar_plateau_west", "resource": preload("res://assets/environment/terrain/expansion_150mb/cedar_plateau_west.obj"), "offset": Vector3(112.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "granite_crown_east", "resource": preload("res://assets/environment/terrain/expansion_150mb/granite_crown_east.obj"), "offset": Vector3(140.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "granite_foothill_east", "resource": preload("res://assets/environment/terrain/expansion_150mb/granite_foothill_east.obj"), "offset": Vector3(168.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "granite_ravine_west", "resource": preload("res://assets/environment/terrain/expansion_150mb/granite_ravine_west.obj"), "offset": Vector3(196.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "granite_ridge_summit", "resource": preload("res://assets/environment/terrain/expansion_150mb/granite_ridge_summit.obj"), "offset": Vector3(224.0, 0.0, 28.0)},
	{"district": "PineHighlands", "tile": "mountain_pass_upper", "resource": preload("res://assets/environment/terrain/expansion_150mb/mountain_pass_upper.obj"), "offset": Vector3(252.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "desert_mesa_fields", "resource": preload("res://assets/environment/terrain/expansion_150mb/desert_mesa_fields.obj"), "offset": Vector3(112.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "desert_wash_plateau", "resource": preload("res://assets/environment/terrain/expansion_150mb/desert_wash_plateau.obj"), "offset": Vector3(140.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "orchard_copse_hills", "resource": preload("res://assets/environment/terrain/expansion_150mb/orchard_copse_hills.obj"), "offset": Vector3(168.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "orchard_ridge_south", "resource": preload("res://assets/environment/terrain/expansion_150mb/orchard_ridge_south.obj"), "offset": Vector3(196.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "orchard_terraces_north", "resource": preload("res://assets/environment/terrain/expansion_150mb/orchard_terraces_north.obj"), "offset": Vector3(224.0, 0.0, 28.0)},
	{"district": "AmberValley", "tile": "red_canyon_rim_north", "resource": preload("res://assets/environment/terrain/expansion_150mb/red_canyon_rim_north.obj"), "offset": Vector3(252.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "basalt_coastal_spur", "resource": preload("res://assets/environment/terrain/expansion_150mb/basalt_coastal_spur.obj"), "offset": Vector3(112.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "sapphire_coast_rock_shelf", "resource": preload("res://assets/environment/terrain/expansion_150mb/sapphire_coast_rock_shelf.obj"), "offset": Vector3(140.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "sapphire_wind_headland", "resource": preload("res://assets/environment/terrain/expansion_300mb/sapphire_wind_headland.obj"), "offset": Vector3(168.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "seagrass_coastal_plain", "resource": preload("res://assets/environment/terrain/expansion_300mb/seagrass_coastal_plain.obj"), "offset": Vector3(196.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "whitecliff_staircase", "resource": preload("res://assets/environment/terrain/expansion_300mb/whitecliff_staircase.obj"), "offset": Vector3(224.0, 0.0, 28.0)},
	{"district": "SapphireCoast", "tile": "red_bridge_ravine_east", "resource": preload("res://assets/environment/terrain/expansion_300mb/red_bridge_ravine_east.obj"), "offset": Vector3(252.0, 0.0, 28.0)},
	{"district": "HarborCity", "tile": "harbor_estuary_banks", "resource": preload("res://assets/environment/terrain/expansion_90mb/harbor_estuary_banks.obj"), "offset": Vector3(280.0, 0.0, 0.0)},
	{"district": "HarborCity", "tile": "harbor_mangrove_flats", "resource": preload("res://assets/environment/terrain/expansion_90mb/harbor_mangrove_flats.obj"), "offset": Vector3(308.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "pine_snowline_ridge", "resource": preload("res://assets/environment/terrain/expansion_90mb/pine_snowline_ridge.obj"), "offset": Vector3(280.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "pine_mist_basin", "resource": preload("res://assets/environment/terrain/expansion_90mb/pine_mist_basin.obj"), "offset": Vector3(308.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "amber_red_canyon", "resource": preload("res://assets/environment/terrain/expansion_90mb/amber_red_canyon.obj"), "offset": Vector3(280.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "amber_wheat_terraces", "resource": preload("res://assets/environment/terrain/expansion_90mb/amber_wheat_terraces.obj"), "offset": Vector3(308.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "sapphire_tidepool_cliffs", "resource": preload("res://assets/environment/terrain/expansion_90mb/sapphire_tidepool_cliffs.obj"), "offset": Vector3(280.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "sapphire_coral_ridge", "resource": preload("res://assets/environment/terrain/expansion_90mb/sapphire_coral_ridge.obj"), "offset": Vector3(308.0, 0.0, 0.0)},
	{"district": "HarborCity", "tile": "harbor_estuary_banks", "resource": preload("res://assets/environment/terrain/expansion_300mb/harbor_estuary_banks.obj"), "offset": Vector3(280.0, 0.0, 0.0)},
	{"district": "HarborCity", "tile": "harbor_mangrove_flats", "resource": preload("res://assets/environment/terrain/expansion_300mb/harbor_mangrove_flats.obj"), "offset": Vector3(308.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "pine_snowline_ridge", "resource": preload("res://assets/environment/terrain/expansion_300mb/pine_snowline_ridge.obj"), "offset": Vector3(280.0, 0.0, 0.0)},
	{"district": "PineHighlands", "tile": "pine_mist_basin", "resource": preload("res://assets/environment/terrain/expansion_300mb/pine_mist_basin.obj"), "offset": Vector3(308.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "amber_red_canyon", "resource": preload("res://assets/environment/terrain/expansion_300mb/amber_red_canyon.obj"), "offset": Vector3(280.0, 0.0, 0.0)},
	{"district": "AmberValley", "tile": "amber_wheat_terraces", "resource": preload("res://assets/environment/terrain/expansion_300mb/amber_wheat_terraces.obj"), "offset": Vector3(308.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "sapphire_tidepool_cliffs", "resource": preload("res://assets/environment/terrain/expansion_300mb/sapphire_tidepool_cliffs.obj"), "offset": Vector3(280.0, 0.0, 0.0)},
	{"district": "SapphireCoast", "tile": "sapphire_coral_ridge", "resource": preload("res://assets/environment/terrain/expansion_300mb/sapphire_coral_ridge.obj"), "offset": Vector3(308.0, 0.0, 0.0)},
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
	tile.visibility_range_end = 420.0
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
