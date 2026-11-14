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
	if int(regions.call("get_population_count")) != 8:
		_fail("The four districts did not create their civilian population.")
		return
	for region_id in ["harbor_city", "pine_highlands", "amber_valley", "sapphire_coast"]:
		if regions.get_node_or_null(str(region_id).to_pascal_case()) == null:
			_fail("A named district node is missing: " + str(region_id))
			return
	print("PASS: Four world districts, 24 building shells and eight scheduled civilians.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
