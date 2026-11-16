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
	if int(regions.call("get_building_count")) != 24:
		_fail("The four districts did not create the expected building blockout.")
		return
	for region_id in ["harbor_city", "pine_highlands", "amber_valley", "sapphire_coast"]:
		var district := regions.get_node(str(region_id).to_pascal_case())
		var ground := district.get_node("DistrictGround") as MeshInstance3D
		if ground.material_override == null or (ground.material_override as StandardMaterial3D).albedo_texture == null:
			_fail("A district ground surface texture is missing: " + str(region_id))
			return
	var harbor_road := regions.get_node("RoadTo_harbor_city") as MeshInstance3D
	if harbor_road.material_override == null or (harbor_road.material_override as StandardMaterial3D).albedo_texture == null:
		_fail("The regional asphalt road texture is missing.")
		return
	if int(regions.call("get_population_count")) != 8:
		_fail("The four districts did not create their civilian population.")
		return
	for region_id in ["harbor_city", "pine_highlands", "amber_valley", "sapphire_coast"]:
		if regions.get_node_or_null(str(region_id).to_pascal_case()) == null:
			_fail("A named district node is missing: " + str(region_id))
			return
	print("PASS: Four textured world districts, asphalt roads, 24 building shells and eight scheduled civilians.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
