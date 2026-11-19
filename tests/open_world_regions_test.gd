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
	if int(regions.call("get_detail_count")) < 180:
		_fail("The four districts did not create their facade and street details.")
		return
	for region_id in ["harbor_city", "pine_highlands", "amber_valley", "sapphire_coast"]:
		if regions.get_node_or_null(str(region_id).to_pascal_case()) == null:
			_fail("A named district node is missing: " + str(region_id))
			return
	var required_textures := [
		"res://assets/environment/materials/hd_city_asphalt_cracked.svg",
		"res://assets/environment/materials/hd_harbor_red_brick.svg",
		"res://assets/environment/materials/hd_city_concrete_stains.svg",
		"res://assets/environment/materials/hd_corrugated_iron.svg",
		"res://assets/environment/materials/hd_ceramic_roof_tiles.svg",
		"res://assets/environment/materials/hd_stone_sidewalk.svg",
		"res://assets/environment/materials/hd_shopfront_glass.svg",
		"res://assets/environment/materials/hd_metal_garage_shutter.svg",
		"res://assets/environment/materials/hd_urban_road_marking.svg",
		"res://assets/environment/materials/hd_weathered_wood_fence.svg",
		"res://assets/environment/materials/hd_rusted_steel_pipe.svg"
	]
	for texture_path in required_textures:
		if not FileAccess.file_exists(texture_path):
			_fail("A city material is missing: " + texture_path)
			return
		if FileAccess.get_file_as_bytes(texture_path).size() < 1000000:
			_fail("A city material is incomplete: " + texture_path)
			return
		if load(texture_path) == null:
			_fail("Godot could not import a city material: " + texture_path)
			return
	var harbor := regions.get_node("HarborCity/DistrictBuilding_01") as Node3D
	var walls := harbor.get_node("Walls") as MeshInstance3D
	var wall_material := walls.material_override as StandardMaterial3D
	if wall_material == null or wall_material.albedo_texture == null:
		_fail("Harbor facade is missing its detailed wall texture.")
		return
	var windows := harbor.get_node("FrontWindow_00") as MeshInstance3D
	var window_material := windows.material_override as StandardMaterial3D
	if window_material == null or window_material.albedo_texture == null:
		_fail("Storefront glass texture was not applied.")
		return
	var lane_mark := regions.get_node("RoadLaneMarking_00_harbor_city") as MeshInstance3D
	var lane_material := lane_mark.material_override as StandardMaterial3D
	if lane_material == null or lane_material.albedo_texture == null:
		_fail("Road lane marking material was not applied.")
		return
	var bench := regions.get_node("HarborCity/RestBenchSeat") as MeshInstance3D
	var bench_material := bench.material_override as StandardMaterial3D
	if bench_material == null or bench_material.albedo_texture == null:
		_fail("Weathered timber bench material was not applied.")
		return
	var lamp := regions.get_node("HarborCity/StreetLampPole") as MeshInstance3D
	var lamp_material := lamp.material_override as StandardMaterial3D
	if lamp_material == null or lamp_material.albedo_texture == null:
		_fail("Rusted steel streetlamp material was not applied.")
		return
	var sidewalk := regions.get_node("HarborCity/TexturedSidewalk_North") as MeshInstance3D
	var sidewalk_material := sidewalk.material_override as StandardMaterial3D
	if sidewalk_material == null or sidewalk_material.albedo_texture == null:
		_fail("Sidewalk paving texture was not applied.")
		return
	print("PASS: Four districts plus eleven high-detail materials are attached to roads, lane paint, facades, roofs, glass, metal, timber and sidewalks.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
