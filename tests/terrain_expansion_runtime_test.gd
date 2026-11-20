extends SceneTree

## Headless regression for proximity-based terrain loading, collision, and unloading.
const REGIONS_SCRIPT = preload("res://scripts/world/open_world_regions.gd")
const TERRAIN_SCRIPT = preload("res://scripts/world/terrain_expansion_runtime.gd")
const MAX_ACTIVE_TILES := 6


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var world := Node3D.new()
	root.add_child(world)

	var regions := REGIONS_SCRIPT.new() as Node3D
	regions.name = "OpenWorldRegions"
	world.add_child(regions)

	var expansion := Node.new()
	expansion.name = "TerrainExpansionRuntime"
	expansion.set_script(TERRAIN_SCRIPT)
	world.add_child(expansion)
	await process_frame

	if int(expansion.call("get_catalog_count")) != 76:
		_fail("The complete 76-tile terrain catalog was not preserved.")
		return
	var missing: Array = expansion.call("get_missing_resource_paths")
	if not missing.is_empty():
		_fail("A terrain resource is missing: " + str(missing[0]))
		return
	if int(expansion.call("get_attached_count")) != 0:
		_fail("Terrain should not be attached before a player enters a district.")
		return

	var player := Node3D.new()
	player.name = "TestPlayer"
	player.add_to_group("player")
	world.add_child(player)

	var harbor := regions.get_node_or_null("HarborCity") as Node3D
	if harbor == null:
		_fail("Harbor City district was not created.")
		return
	player.global_position = harbor.global_position
	expansion.call("refresh_for_player", player)
	await process_frame

	var active_names: Array = expansion.call("get_active_tile_names")
	var active_count := int(expansion.call("get_attached_count"))
	if active_count <= 0 or active_count > MAX_ACTIVE_TILES:
		_fail("Nearby terrain did not load within the six-tile active budget.")
		return
	if int(expansion.call("get_collision_count")) != active_count:
		_fail("Every streamed visual terrain tile must have one matching collision body.")
		return
	if not active_names.has("harbor_rail_yards"):
		_fail("The closest Harbor City tile was not selected.")
		return

	var first_visual := harbor.get_node_or_null("ExpansionTerrain_harbor_rail_yards") as MeshInstance3D
	var first_collision := harbor.get_node_or_null("ExpansionTerrainCollision_harbor_rail_yards") as StaticBody3D
	if first_visual == null or first_visual.mesh == null or first_collision == null:
		_fail("The streamed Harbor City visual or collision is missing.")
		return
	var shape := first_collision.get_node_or_null("TerrainCollisionShape") as CollisionShape3D
	if shape == null or not (shape.shape is ConcavePolygonShape3D):
		_fail("The streamed tile did not receive a valid trimesh collision shape.")
		return

	player.global_position = Vector3(10000.0, 0.0, 10000.0)
	expansion.call("refresh_for_player", player)
	await process_frame
	await process_frame
	if int(expansion.call("get_attached_count")) != 0 or int(expansion.call("get_collision_count")) != 0:
		_fail("Distant terrain meshes and collisions were not unloaded.")
		return
	if harbor.get_node_or_null("ExpansionTerrain_harbor_rail_yards") != null:
		_fail("The distant Harbor City visual remained attached after unloading.")
		return

	var coast := regions.get_node_or_null("SapphireCoast") as Node3D
	if coast == null:
		_fail("Sapphire Coast district was not created.")
		return
	player.global_position = coast.global_position
	expansion.call("refresh_for_player", player)
	await process_frame
	var coast_names: Array = expansion.call("get_active_tile_names")
	if not coast_names.has("sapphire_tidal_shelf"):
		_fail("Sapphire Coast terrain did not stream when the player entered the district.")
		return
	if int(expansion.call("get_collision_count")) != int(expansion.call("get_attached_count")):
		_fail("Sapphire Coast streamed collision count does not match its visual tile count.")
		return

	player.global_position = Vector3(10000.0, 0.0, 10000.0)
	expansion.call("refresh_for_player", player)
	await process_frame
	await process_frame
	var high_detail_tiles := [
		{"district": "HarborCity", "tile": "harbor_breakwater_112"},
		{"district": "PineHighlands", "tile": "pine_granite_spur_112"},
		{"district": "AmberValley", "tile": "amber_vineyard_terraces_112"},
		{"district": "SapphireCoast", "tile": "sapphire_tidepool_rim_112"}
	]
	for tile_data in high_detail_tiles:
		var target_district := regions.get_node_or_null(str(tile_data["district"])) as Node3D
		if target_district == null:
			_fail("A district for the new high-detail terrain tile is missing: " + str(tile_data["district"]))
			return
		player.global_position = target_district.to_global(Vector3(280.0, 0.0, 0.0))
		expansion.call("refresh_for_player", player)
		await process_frame
		var tile_name := str(tile_data["tile"])
		var streamed_names: Array = expansion.call("get_active_tile_names")
		var visual := target_district.get_node_or_null("ExpansionTerrain_" + tile_name) as MeshInstance3D
		if not streamed_names.has(tile_name) or visual == null or visual.mesh == null or visual.mesh.get_surface_count() == 0:
			_fail("The new high-detail district terrain did not stream a valid visible mesh: " + tile_name)
			return
		if int(expansion.call("get_collision_count")) != int(expansion.call("get_attached_count")):
			_fail("A high-detail terrain mesh was streamed without a matching collision body: " + tile_name)
			return
		var collision_body := target_district.get_node_or_null("ExpansionTerrainCollision_" + tile_name) as StaticBody3D
		var expected_scale := Vector3(0.126, 0.10, 0.126)
		if visual.scale.distance_to(expected_scale) > 0.001 or collision_body == null or collision_body.scale.distance_to(expected_scale) > 0.001:
			_fail("High-detail terrain and collision must use the 222-unit source mesh scale to meet the 28-unit district grid: " + tile_name)
			return
		var footprint := visual.mesh.get_aabb().size * visual.scale
		if absf(footprint.x - 27.972) > 0.1 or absf(footprint.z - 27.972) > 0.1:
			_fail("High-detail terrain footprint does not match the district tile spacing: " + tile_name)
			return
		if visual.mesh.get_surface_count() < 2:
			_fail("High-detail terrain must keep its regional material bands: " + tile_name)
			return
		var high_detail_shape := collision_body.get_node_or_null("TerrainCollisionShape") as CollisionShape3D
		if high_detail_shape == null or not (high_detail_shape.shape is ConcavePolygonShape3D):
			_fail("High-detail terrain is missing its trimesh collision shape: " + tile_name)
			return

	player.global_position = Vector3(10000.0, 0.0, 10000.0)
	expansion.call("refresh_for_player", player)
	await process_frame
	await process_frame
	if int(expansion.call("get_attached_count")) != 0:
		_fail("The test retained streamed terrain resources at shutdown.")
		return

	print("PASS: 76 terrain resources preserved; four district-specific high-detail meshes stream with collision and unload outside the active radius.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
