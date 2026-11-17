extends SceneTree

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

	if int(expansion.call("get_catalog_count")) != 72:
		_fail("The terrain catalogue must retain all seventy-two unique district tiles.")
		return
	var missing: Array = expansion.call("get_missing_resource_paths")
	if not missing.is_empty():
		_fail("A terrain resource path is missing: " + str(missing[0]))
		return
	if int(expansion.call("get_attached_count")) != 0:
		_fail("Terrain must remain unloaded until a player approaches a district.")
		return

	var harbor := regions.get_node("HarborCity") as Node3D
	var player := Node3D.new()
	player.name = "Player"
	player.add_to_group("player")
	world.add_child(player)
	player.global_position = harbor.global_position
	expansion.call("refresh_for_player", player)
	await process_frame

	var active_names: Array = expansion.call("get_active_tile_names")
	var active_count := int(expansion.call("get_attached_count"))
	if active_count <= 0 or active_count > MAX_ACTIVE_TILES:
		_fail("Nearby terrain must load while respecting the six-tile mobile budget.")
		return
	if int(expansion.call("get_collision_count")) != active_count:
		_fail("Every active terrain tile must have exactly one collision body.")
		return
	if not active_names.has("harbor_rail_yards"):
		_fail("The closest Harbor City tile did not load first.")
		return

	var harbor_visual := harbor.get_node_or_null("ExpansionTerrain_harbor_rail_yards") as MeshInstance3D
	var harbor_collision := harbor.get_node_or_null("ExpansionTerrainCollision_harbor_rail_yards") as StaticBody3D
	if harbor_visual == null or harbor_visual.mesh == null:
		_fail("The nearby Harbor City terrain visual is missing.")
		return
	if harbor_collision == null:
		_fail("The nearby Harbor City terrain collision body is missing.")
		return
	var collision_shape := harbor_collision.get_node_or_null("TerrainCollisionShape") as CollisionShape3D
	if collision_shape == null or not (collision_shape.shape is ConcavePolygonShape3D):
		_fail("The streamed terrain collision shape is invalid.")
		return

	player.global_position = Vector3(10000.0, 0.0, 10000.0)
	expansion.call("refresh_for_player", player)
	await process_frame
	if int(expansion.call("get_attached_count")) != 0 or int(expansion.call("get_collision_count")) != 0:
		_fail("Distant terrain visuals and collision bodies were not unloaded.")
		return

	var coast := regions.get_node("SapphireCoast") as Node3D
	player.global_position = coast.global_position
	expansion.call("refresh_for_player", player)
	await process_frame
	var coast_names: Array = expansion.call("get_active_tile_names")
	if not coast_names.has("sapphire_tidal_shelf"):
		_fail("Terrain did not stream back in when the player entered Sapphire Coast.")
		return

	print("PASS: 72 terrain resources are catalogued; nearby tiles stream in with collision, distant tiles unload, and another district reloads.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
