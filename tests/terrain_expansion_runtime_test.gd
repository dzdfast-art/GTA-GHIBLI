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
		_fail("Expected all thirty-two regional terrain tiles to attach.")
		return
	if int(expansion.call("get_collision_count")) != EXPECTED_TILES.size():
		_fail("Expected static collision for all thirty-two regional terrain tiles.")
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

	print("PASS: thirty-two regional terrain meshes and static collision bodies loaded.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
