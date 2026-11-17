extends SceneTree

const REGIONS_SCRIPT = preload("res://scripts/world/open_world_regions.gd")
const TERRAIN_SCRIPT = preload("res://scripts/world/terrain_expansion_runtime.gd")
const EXPECTED_TILES := [
	["HarborCity", "harbor_rail_yards"],
	["HarborCity", "harbor_tidal_marsh"],
	["HarborCity", "harbor_container_flats"],
	["PineHighlands", "pine_cedar_ridge"],
	["PineHighlands", "pine_misty_bowl"],
	["PineHighlands", "pine_needle_ridge"],
	["AmberValley", "amber_orchard_slope"],
	["AmberValley", "amber_rolling_fields"],
	["AmberValley", "amber_orchard_steps"],
	["SapphireCoast", "sapphire_tidal_shelf"],
	["SapphireCoast", "sapphire_sea_cliffs"],
	["SapphireCoast", "sapphire_coral_shelf"],
	["HarborCity", "harbor_floodplain_west"],
	["HarborCity", "harbor_old_quarry"],
	["HarborCity", "harbor_outer_marsh"],
	["HarborCity", "harbor_rail_flats"],
	["HarborCity", "urban_canal_banks"],
	["PineHighlands", "highland_switchbacks"],
	["PineHighlands", "northern_forest_bowl"],
	["PineHighlands", "pine_fog_valley"],
	["PineHighlands", "pine_forest_bowl"],
	["PineHighlands", "pine_needle_uplands"],
	["AmberValley", "amber_river_meanders"],
	["AmberValley", "amber_valley_terraces"],
	["AmberValley", "amber_wheat_basin"],
	["AmberValley", "farm_irrigation_fields"],
	["AmberValley", "farmstead_lowlands"],
	["SapphireCoast", "basalt_coast_shelves"],
	["SapphireCoast", "coastal_bluff_west"],
	["SapphireCoast", "sapphire_headland_east"],
	["SapphireCoast", "sapphire_tidal_flats"],
	["SapphireCoast", "sapphire_wind_cliffs"],
	["HarborCity", "harbor_dredge_basin"],
	["HarborCity", "heron_marsh_backwater"],
	["HarborCity", "saltmarsh_lagoon_east"],
	["HarborCity", "riverstone_delta_bars"],
	["PineHighlands", "pine_stone_pass"],
	["PineHighlands", "pine_stone_ridge"],
	["PineHighlands", "cedar_cloud_summit"],
	["PineHighlands", "windward_pine_escarpment"],
	["AmberValley", "amber_dry_wash"],
	["AmberValley", "copper_badlands_ridge"],
	["AmberValley", "mesa_terrace_south"],
	["AmberValley", "ochre_dry_wash"],
	["SapphireCoast", "sapphire_salt_lagoon"],
	["SapphireCoast", "sapphire_tidal_bench"],
	["SapphireCoast", "sapphire_tidepools_north"],
	["SapphireCoast", "coral_shelf_headland"],
	["HarborCity", "marsh_channel_west"],
	["HarborCity", "willow_marsh_islands"],
	["HarborCity", "river_delta_east"],
	["HarborCity", "wetland_reed_plain"],
	["HarborCity", "lake_mirror_basin"],
	["HarborCity", "willow_village_outer_hills"],
	["PineHighlands", "cedar_plateau_west"],
	["PineHighlands", "granite_crown_east"],
	["PineHighlands", "granite_foothill_east"],
	["PineHighlands", "granite_ravine_west"],
	["PineHighlands", "granite_ridge_summit"],
	["PineHighlands", "mountain_pass_upper"],
	["AmberValley", "desert_mesa_fields"],
	["AmberValley", "desert_wash_plateau"],
	["AmberValley", "orchard_copse_hills"],
	["AmberValley", "orchard_ridge_south"],
	["AmberValley", "orchard_terraces_north"],
	["AmberValley", "red_canyon_rim_north"],
	["SapphireCoast", "basalt_coastal_spur"],
	["SapphireCoast", "sapphire_coast_rock_shelf"],
	["SapphireCoast", "sapphire_wind_headland"],
	["SapphireCoast", "seagrass_coastal_plain"],
	["SapphireCoast", "whitecliff_staircase"],
	["SapphireCoast", "red_bridge_ravine_east"],
	["HarborCity", "harbor_estuary_sandbars"],
	["HarborCity", "harbor_mangrove_runnels"],
	["PineHighlands", "pine_snowline_spurs"],
	["PineHighlands", "pine_mist_lakes"],
	["AmberValley", "amber_canyon_ravines"],
	["AmberValley", "amber_wheat_terraces_west"],
	["SapphireCoast", "sapphire_tidepool_bays"],
	["SapphireCoast", "sapphire_coral_spurs"],
	["HarborCity", "harbor_estuary_banks"],
	["HarborCity", "harbor_mangrove_flats"],
	["PineHighlands", "pine_snowline_ridge"],
	["PineHighlands", "pine_mist_basin"],
	["AmberValley", "amber_red_canyon"],
	["AmberValley", "amber_wheat_terraces"],
	["SapphireCoast", "sapphire_tidepool_cliffs"],
	["SapphireCoast", "sapphire_coral_ridge"],
]

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var regions := REGIONS_SCRIPT.new() as Node3D
	regions.name = "OpenWorldRegions"
	world.add_child(regions)
	var expansion := Node.new()
	expansion.set_script(TERRAIN_SCRIPT)
	expansion.name = "TerrainExpansionRuntime"
	world.add_child(expansion)
	await process_frame

	if int(expansion.call("get_attached_count")) != EXPECTED_TILES.size():
		_fail("Expected all eighty-eight regional terrain tiles to attach.")
		return
	if int(expansion.call("get_collision_count")) != EXPECTED_TILES.size():
		_fail("Expected static collision for all eighty-eight regional terrain tiles.")
		return

	for tile_spec in EXPECTED_TILES:
		var district_name: String = tile_spec[0]
		var tile_name: String = tile_spec[1]
		var district := regions.get_node_or_null(district_name)
		if district == null:
			_fail("Missing district " + district_name)
			return
		var tile := district.get_node_or_null("ExpansionTerrain_" + tile_name) as MeshInstance3D
		if tile == null or tile.mesh == null:
			_fail("Terrain mesh is empty for " + tile_name)
			return
		var body := district.get_node_or_null("ExpansionTerrainCollision_" + tile_name) as StaticBody3D
		if body == null:
			_fail("Terrain collision body is missing for " + tile_name)
			return
		var collision := body.get_node_or_null("TerrainCollisionShape") as CollisionShape3D
		if collision == null or not (collision.shape is ConcavePolygonShape3D):
			_fail("Terrain collision shape is missing or invalid for " + tile_name)
			return

	print("PASS: eighty-eight regional terrain meshes and static collision bodies loaded.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
