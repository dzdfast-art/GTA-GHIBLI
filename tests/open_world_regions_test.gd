extends SceneTree

const REGIONS_SCRIPT = preload("res://scripts/world/open_world_regions.gd")

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var regions := Node3D.new()
	regions.set_script(REGIONS_SCRIPT)
	root.add_child(regions)
	if regions.call("get_region_ids").size() != 4:
		_fail("The open-world region director did not create four districts.")
		return
	if int(regions.call("get_building_count")) != 34:
		_fail("The four districts did not create sixteen detailed Harbor City houses and eighteen other building shells.")
		return
	if int(regions.call("get_population_count")) != 8:
		_fail("The four districts did not create their civilian population.")
		return
	var harbor := regions.get_node("HarborCity") as Node3D
	var house_collection := harbor.get_node_or_null("HarborResidentialMesh") as MeshInstance3D
	var road_collection := harbor.get_node_or_null("HarborStreetNetworkMesh") as MeshInstance3D
	if house_collection == null or house_collection.mesh == null or house_collection.mesh.get_surface_count() < 4:
		_fail("Harbor City must load its original multi-material low-rise house collection.")
		return
	if road_collection == null or road_collection.mesh == null or road_collection.mesh.get_surface_count() < 3:
		_fail("Harbor City must load its original road, curb and sidewalk collection.")
		return
	if harbor.get_children().filter(func(node): return str(node.name).begins_with("HarborHouseCollision_")).size() != 16:
		_fail("Harbor City must keep 16 collision footprints for its 16 houses.")
		return

	for region_id in ["harbor_city", "pine_highlands", "amber_valley", "sapphire_coast"]:
		var district := regions.get_node_or_null(str(region_id).to_pascal_case()) as Node3D
		if district == null:
			_fail("A named district node is missing: " + str(region_id))
			return
		var ground := district.get_node_or_null("DistrictGround") as MeshInstance3D
		if ground == null:
			_fail("A district is missing its ground mesh: " + str(region_id))
			return
		var surface_material := ground.material_override as StandardMaterial3D
		if surface_material == null or surface_material.albedo_texture == null:
			_fail("The SVG ground surface texture did not load for district: " + str(region_id))
			return
	var navigation_regions := get_nodes_in_group("world_navigation_regions")
	if navigation_regions.size() != 4:
		_fail("Each district must own a navigation region.")
		return
	for region in navigation_regions:
		var navigation_mesh := (region as NavigationRegion3D).navigation_mesh
		if navigation_mesh == null or navigation_mesh.get_polygon_count() < 40:
			_fail("District navigation mesh is missing its walkable cell polygons.")
			return

	for _frame in range(6):
		await physics_frame
	var npc_brains := get_nodes_in_group("npc_brains")
	if npc_brains.size() < 8:
		_fail("All eight district civilians must have navigation brains.")
		return
	for brain in npc_brains:
		if not brain.call("has_navigation_agent") or not brain.call("has_navigation_map"):
			_fail("A district civilian does not have a live NavigationAgent3D map.")
			return
	var sample_brain: Node = npc_brains[0]
	var sample_actor := sample_brain.get_parent() as Node3D
	var sample_agent := sample_brain.get_node("NavigationAgent3D") as NavigationAgent3D
	var destination := sample_actor.global_position + Vector3(-2.0, 0.0, -2.0)
	sample_agent.target_position = destination
	for _frame in range(6):
		await physics_frame
	if sample_agent.get_current_navigation_path().size() < 2:
		_fail("A civilian could not calculate a path through its district navigation grid.")
		return

	print("PASS: Four world districts, 24 building shells, eight scheduled civilians and live NavMesh paths.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
