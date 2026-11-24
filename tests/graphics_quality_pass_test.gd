extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var main := MAIN_SCENE.instantiate() as Node3D
	root.add_child(main)
	await process_frame
	await process_frame

	var player := main.get_node_or_null("Player") as CharacterBody3D
	if player == null:
		_fail("Main scene did not create the player.")
		return
	var visual := player.get_node_or_null("Visual") as MeshInstance3D
	if visual == null or visual.mesh != null:
		_fail("The capsule placeholder was not replaced by the stylized player visual.")
		return
	for part_name in ["Head", "HairCap", "Hood", "GhibliBackLogo", "SneakerUpper"]:
		if part_name == "SneakerUpper":
			if visual.get_node_or_null("LegPivot_Left/SneakerUpper") == null:
				_fail("Missing stylized player part: " + part_name)
				return
		elif visual.get_node_or_null(part_name) == null:
			_fail("Missing stylized player part: " + part_name)
			return

	var car := main.get_node_or_null("StarterCar")
	if car == null or car.get_node_or_null("Spoiler") == null:
		_fail("The upgraded red starter car visuals were not created.")
		return

	var harbor := main.get_node_or_null("OpenWorldRegions/HarborCity") as Node3D
	if harbor == null:
		_fail("Harbor City was not created.")
		return
	var tower := harbor.get_node_or_null("GhibliSkyline/Tower_03") as Node3D
	if tower == null:
		_fail("The Harbor City skyline was not created.")
		return
	var windows := tower.get_node_or_null("WindowInstances") as MultiMeshInstance3D
	if windows == null or windows.multimesh == null or windows.multimesh.instance_count < 80:
		_fail("The skyline tower does not have its expected instanced window details.")
		return

	var hoodie := visual.get_node_or_null("HoodieBody") as MeshInstance3D
	if hoodie == null or hoodie.material_override == null or (hoodie.material_override as StandardMaterial3D).albedo_texture == null:
		_fail("The player hoodie fabric texture was not imported.")
		return

	var car_body := car.get_node_or_null("LowerBody") as MeshInstance3D
	if car_body == null or car_body.material_override == null or (car_body.material_override as StandardMaterial3D).albedo_texture == null:
		_fail("The sports-car paint texture was not imported.")
		return

	var opening_road := main.get_node_or_null("GhibliVisualPass/ReferenceStreetComposition/OpeningBoulevard") as MeshInstance3D
	if opening_road == null or opening_road.material_override == null or (opening_road.material_override as StandardMaterial3D).albedo_texture == null:
		_fail("The opening boulevard asphalt texture was not imported.")
		return

	var facade := main.get_node_or_null("GhibliVisualPass/ReferenceStreetComposition/OpeningSkyline/OpeningTower_Center/Facade") as MeshInstance3D
	if facade == null or facade.material_override == null or (facade.material_override as StandardMaterial3D).albedo_texture == null:
		_fail("The city facade texture was not imported.")
		return

	var village := main.get_node_or_null("WillowVillage/GhibliCherryBlossoms") as Node3D
	if village == null or village.get_node_or_null("BlossomTree_01") == null:
		_fail("The village cherry-blossom additions were not created.")
		return

	print("PASS: stylized player, upgraded sports car, instanced Harbor City skyline, and village blossom trees.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
