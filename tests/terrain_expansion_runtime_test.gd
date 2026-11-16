extends SceneTree

const REGIONS_SCRIPT = preload("res://scripts/world/open_world_regions.gd")
const TERRAIN_SCRIPT = preload("res://scripts/world/terrain_expansion_runtime.gd")

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
	if int(expansion.call("get_attached_count")) != 4:
		_fail("Expected one terrain tile in each of the four districts.")
		return
	if int(expansion.call("get_collision_count")) != 4:
		_fail("Expected static terrain collision in all four districts.")
		return
	for district_name in ["HarborCity", "PineHighlands", "AmberValley", "SapphireCoast"]:
		var district := regions.get_node_or_null(district_name)
		if district == null:
			_fail("Missing district " + district_name)
			return
		var tile := district.get_node_or_null("ExpansionTerrain_" + district_name) as MeshInstance3D
		if tile == null or tile.mesh == null:
			_fail("Terrain mesh is empty for " + district_name)
			return
		var body := district.get_node_or_null("ExpansionTerrainCollision_" + district_name) as StaticBody3D
		if body == null:
			_fail("Terrain collision body is missing for " + district_name)
			return
		var collision := body.get_node_or_null("TerrainCollisionShape") as CollisionShape3D
		if collision == null or not (collision.shape is ConcavePolygonShape3D):
			_fail("Terrain collision shape is missing or invalid for " + district_name)
			return
	print("PASS: four regional terrain meshes and static collision bodies loaded.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
