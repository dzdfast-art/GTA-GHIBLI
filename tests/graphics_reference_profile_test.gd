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
	var fresh_wallet := Node.new()
	fresh_wallet.set_script(preload("res://scripts/systems/player_wallet.gd"))
	fresh_wallet.set("persistence_enabled", false)
	root.add_child(fresh_wallet)
	if int(fresh_wallet.call("get_balance")) != 350:
		_fail("A new game should start with the reference cash balance of $350.")
		return

	var player := game.get_node_or_null("Player") as CharacterBody3D
	if player == null:
		_fail("Reference-profile test cannot find the playable character.")
		return
	var visual := player.get_node_or_null("Visual")
	if visual == null:
		_fail("The player must expose the original humanoid visual.")
		return
	player.velocity = Vector3(0.0, 0.0, -5.0)
	visual.call("_process", 0.12)
	if float(visual.call("get_locomotion_weight")) < 0.1:
		_fail("The protagonist's gait must react to real movement velocity, including touch-driven movement.")
		return
	player.velocity = Vector3.ZERO
	visual.call("_process", 0.12)
	if float(visual.call("get_locomotion_weight")) >= 0.9:
		_fail("The protagonist's gait must ease back toward idle when movement stops.")
		return
	for required_part in ["Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "BackPocketLeft", "BackPocketRight", "BeltBuckle", "LeftShoeSole", "RightShoeSole"]:
		if visual.get_node_or_null(required_part) == null:
			_fail("The protagonist is missing a reference silhouette detail: " + required_part)
			return

	var shirt_mesh := visual.get_node("Torso/Shirt") as MeshInstance3D
	var jeans_mesh := visual.get_node("LeftLeg/Pants") as MeshInstance3D
	var shoe_mesh := visual.get_node("LeftLeg/Shoe") as MeshInstance3D
	for clothing_mesh in [shirt_mesh, jeans_mesh, shoe_mesh]:
		var clothing_material := clothing_mesh.material_override as StandardMaterial3D if clothing_mesh != null else null
		if clothing_material == null or clothing_material.albedo_texture == null:
			_fail("The protagonist's white top, denim or shoes are missing their fabric texture.")
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

	var controls := game.get_node_or_null("MobileControls")
	var controls_root := controls.get_node_or_null("HUD") as Control if controls != null else null
	if controls_root == null:
		_fail("The mobile HUD control layer is missing.")
		return
	var context_button := controls_root.get_node_or_null("ContextAction") as Button
	var sprint_button := controls_root.get_node_or_null("Sprint") as Button
	if context_button == null or sprint_button == null or context_button.icon == null or sprint_button.icon == null:
		_fail("Reference-style bicycle and run action icons are missing.")
		return
	var button_style := context_button.get_theme_stylebox("normal") as StyleBoxFlat
	if button_style == null or button_style.bg_color.r > 0.20 or button_style.bg_color.a > 0.85:
		_fail("Mobile action buttons must use dark, translucent circular backgrounds.")
		return
	if context_button.text != "" or sprint_button.text != "":
		_fail("Primary mobile actions should use icon-only controls like the reference HUD.")
		return
	var joystick := controls_root.get_node_or_null("MovementJoystick") as Control
	if joystick == null or joystick.size.x < 170.0:
		_fail("The reference-sized analog joystick is missing.")
		return
	var gameplay_hud := controls.get_node_or_null("GameplayHUD") as Control
	var radar := gameplay_hud.get_node_or_null("LiveRadar") as Control if gameplay_hud != null else null
	var fist_icon := gameplay_hud.get_node_or_null("PlayerStatus/ClockRow/UnarmedFistIcon") as TextureRect if gameplay_hud != null else null
	if radar == null or radar.custom_minimum_size.x < 175.0 or fist_icon == null or fist_icon.custom_minimum_size.x < 55.0:
		_fail("The reference-sized circular minimap or fist HUD icon is missing.")
		return
	if get_nodes_in_group("radar_buildings").size() < 30:
		_fail("World buildings are not registered for map block outlines.")
		return
	var clock_row := gameplay_hud.get_node("PlayerStatus/ClockRow") as HBoxContainer
	if clock_row.get_child_count() < 2 or clock_row.get_child(clock_row.get_child_count() - 1) != fist_icon:
		_fail("The fist icon should sit to the right of the in-game clock, as in the reference HUD.")
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
	# Node.set_name() normalizes the decimal point in generated names to an underscore.
	var lamp := village.get_node_or_null("VillageStreetLamp_-1_0_0/ImportedMesh") as MeshInstance3D
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
		if vehicle.get_node_or_null("DoorHandle_-1") == null or vehicle.get_node_or_null("FrontGrille") == null:
			_fail("An ambient sedan is missing body details.")
			return
		if vehicle.get_node_or_null("WheelHub_-1_-1") == null:
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
