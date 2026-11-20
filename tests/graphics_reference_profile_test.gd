extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := MAIN_SCENE.instantiate()
	root.add_child(game)
	for _frame in range(8):
		await process_frame
		await physics_frame

	var clock := game.get_node_or_null("WorldClock")
	if clock == null or str(clock.call("get_clock_text")) != "06:51":
		_fail("The opening scene should start at the reference morning time of 06:51.")
		return
	var player := game.get_node_or_null("Player") as CharacterBody3D
	if player == null:
		_fail("Reference-profile test cannot find the playable character.")
		return
	var visual := player.get_node_or_null("Visual")
	if visual == null:
		_fail("The player must expose the original humanoid visual.")
		return
	for required_part in ["Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "BackPocketLeft", "BackPocketRight", "BeltBuckle", "LeftShoeSole", "RightShoeSole"]:
		if visual.get_node_or_null(required_part) == null:
			_fail("The protagonist is missing a reference silhouette detail: " + required_part)
			return

	var camera_pivot := player.get_node_or_null("CameraPivot") as Node3D
	var spring_arm := player.get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D
	var camera := player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	if camera_pivot == null or spring_arm == null or camera == null:
		_fail("The third-person camera rig is incomplete.")
		return
	if absf(spring_arm.spring_length - 3.6) > 0.01 or absf(camera.fov - 65.0) > 0.01:
		_fail("The camera must use the reference-matched follow distance and field of view.")

	player.set("is_driving", true)
	for _frame in range(12):
		await process_frame
	if spring_arm.spring_length < 4.4:
		_fail("The camera should pull back smoothly while riding a vehicle.")
		return
	player.set("is_driving", false)
	for _frame in range(12):
		await process_frame
	if spring_arm.spring_length > 4.5:
		_fail("The camera should return to the closer on-foot framing after dismount.")
		return

	var village := game.get_node_or_null("WillowVillage")
	if village == null:
		_fail("The starting village is missing.")
		return
	var alley := village.get_node_or_null("ReferenceAlleyAsphalt") as MeshInstance3D
	var wall := village.get_node_or_null("ReferenceAlleyStoneWall") as MeshInstance3D
	var alley_material := alley.material_override as StandardMaterial3D if alley != null else null
	if alley == null or wall == null or alley_material == null or alley_material.albedo_texture == null:
		_fail("The opening alley must have textured asphalt and stone wall surfaces.")
		return
	var tree := village.get_node_or_null("WillowTree_00/ImportedMesh") as MeshInstance3D
	if tree == null or tree.mesh == null or tree.mesh.get_surface_count() < 2:
		_fail("The village must use the original multi-material low-poly willow tree.")
		return
	var lamp := village.get_node_or_null("VillageStreetLamp_-1.0_0/ImportedMesh") as MeshInstance3D
	if lamp == null or lamp.mesh == null:
		_fail("The street scene must use the original low-poly street lamp model.")
		return

	var harbor := game.get_node_or_null("OpenWorldRegions/HarborCity") as Node3D
	if harbor == null:
		_fail("The Harbor City visual collection is missing.")
		return
	for node_name in ["HarborResidentialMesh", "HarborStreetNetworkMesh"]:
		var imported := harbor.get_node_or_null(node_name) as MeshInstance3D
		if imported == null or imported.mesh == null or imported.mesh.get_surface_count() < 3:
			_fail("Harbor City is missing its detailed original mesh collection: " + node_name)
			return

	var traffic := get_nodes_in_group("ambient_traffic_vehicles")
	if traffic.size() < 4:
		_fail("Reference-style street traffic must contain at least four cars.")
		return
	for vehicle in traffic:
		if vehicle.get_node_or_null("DoorHandle_-1.0") == null or vehicle.get_node_or_null("FrontGrille") == null:
			_fail("An ambient sedan is missing body details.")
			return
		if vehicle.get_node_or_null("WheelHub_-1.0_-1.0") == null:
			_fail("An ambient sedan is missing its wheel hubs.")
			return

	var world_environment := get_nodes_in_group("quality_managed_world_environment")
	if world_environment.size() != 1:
		_fail("The world must expose one consistent outdoor color and lighting profile.")
		return
	var environment := (world_environment[0] as WorldEnvironment).environment
	if environment.glow_enabled:
		_fail("The reference profile should not use strong modern bloom glow.")
		return

	print("PASS: GTA SA Mobile reference profile — low-poly protagonist, third-person framing, textured alley, original props, Harbor City assets, detailed traffic sedans and warm non-bloom outdoor lighting.")
	game.queue_free()
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
