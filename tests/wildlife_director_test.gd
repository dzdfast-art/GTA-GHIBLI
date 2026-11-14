extends SceneTree

const REGIONS_SCRIPT = preload("res://scripts/world/open_world_regions.gd")
const WILDLIFE_DIRECTOR_SCRIPT = preload("res://scripts/world/wildlife_director.gd")

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var regions := Node3D.new()
	regions.name = "OpenWorldRegions"
	regions.set_script(REGIONS_SCRIPT)
	world.add_child(regions)
	var director := Node3D.new()
	director.set_script(WILDLIFE_DIRECTOR_SCRIPT)
	world.add_child(director)
	if int(director.call("get_wildlife_count")) != 12:
		_fail("Wildlife director did not create all habitat animals.")
		return
	var counts: Dictionary = director.call("get_species_counts")
	if int(counts.get("deer", 0)) != 3 or int(counts.get("rabbit", 0)) != 5 or int(counts.get("gull", 0)) != 4:
		_fail("The wildlife species population does not match the habitat plan.")
		return
	for region_name in ["PineHighlands", "AmberValley", "SapphireCoast"]:
		var habitat := regions.get_node_or_null(region_name)
		if habitat == null or habitat.get_child_count() < 1:
			_fail("Wildlife habitat is missing: " + region_name)
			return
	print("PASS: Three habitats populated with deer, rabbits and gulls.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
