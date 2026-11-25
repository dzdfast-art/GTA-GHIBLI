extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var main := MAIN_SCENE.instantiate() as Node3D
	root.add_child(main)
	await process_frame
	await process_frame

	var world_environment := main.get_node_or_null("GhibliVisualPass/GhibliWorldEnvironment") as WorldEnvironment
	if world_environment == null or world_environment.environment == null:
		_fail("The Ghibli world environment was not created.")
		return
	if world_environment.environment.ambient_light_energy < 0.5:
		_fail("The ambient fill light is below the configured minimum.")
		return
	var sun := main.get_node_or_null("GhibliVisualPass/GhibliDaylightSun") as DirectionalLight3D
	if sun == null or not sun.shadow_enabled or sun.light_energy <= 0.0:
		_fail("The daylight sun or its real-time shadows are missing.")
		return

	var player := main.get_node_or_null("Player") as CharacterBody3D
	if player == null:
		_fail("Main scene did not create the player.")
		return
	var visual := player.get_node_or_null("Visual") as MeshInstance3D
	if visual == null or visual.mesh != null:
		_fail("The capsule placeholder was not replaced by the stylized player visual.")
		return
	var imported_hero := visual.get_node_or_null("PBR_GhibliHero") as Node3D
	if imported_hero == null:
		_fail("The imported articulated PBR hero model was not instantiated.")
		return
	for part_path in [
		"Head",
		"HairCap",
		"Hood",
		"LegPivot_Left/SneakerUpper",
		"LegPivot_Right/SneakerUpper",
		"ArmPivot_Left/HoodieSleeve",
		"ArmPivot_Right/HoodieSleeve"
	]:
		if imported_hero.find_child(part_path.get_file(), true, false) == null:
			_fail("Missing imported PBR hero part: " + part_path)
			return
	if visual.get_node_or_null("GhibliBackLogo") == null:
		_fail("The GTA GHIBLI back logo was not placed on the imported hero.")
		return

	var car := main.get_node_or_null("StarterCar")
	if car == null:
		_fail("The starter car was not created.")
		return
	var pbr_car := car.get_node_or_null("PBR_SportCoupe") as Node3D
	if pbr_car == null:
		_fail("The imported PBR sport coupe model was not instantiated.")
		return
	for part_name in ["Body_Painted_Shell", "Cabin_Roof_And_Pillars", "Glazing_And_Seals", "Leather_Interior", "Lighting_Units", "Front_Grille_And_Exhaust"]:
		var part := pbr_car.find_child(part_name, true, false) as MeshInstance3D
		if part == null or part.mesh == null or part.mesh.get_surface_count() < 1:
			_fail("Missing imported PBR vehicle geometry: " + part_name)
			return
	for wheel_name in ["Wheel_Front_Left", "Wheel_Front_Right", "Wheel_Rear_Left", "Wheel_Rear_Right"]:
		if pbr_car.find_child(wheel_name, true, false) == null:
			_fail("Missing independently rotating PBR wheel: " + wheel_name)
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

	var harbor_street := harbor.get_node_or_null("HarborStreetFurniture") as Node3D
	if harbor_street == null:
		_fail("Harbor street furniture was not created.")
		return
	var crossing := harbor_street.get_node_or_null("PedestrianCrossing") as Node3D
	if crossing == null or crossing.get_child_count() != 7:
		_fail("The harbor zebra crossing must contain seven visible stripes.")
		return
	if get_nodes_in_group("harbor_street_lamps").size() != 4:
		_fail("The harbor boulevard must contain four street lamps.")
		return

	# GLES3 mobile fallback: emissive lamp housings must not create four
	# realtime OmniLights that exceed the emulator's fragment-uniform budget.
	if harbor_street.find_children("*", "OmniLight3D", true, false).size() != 0:
		_fail("Harbor street lamps must use emissive materials, not realtime OmniLights, on the GLES3 mobile renderer.")
		return
	var emissive_lamp_count := 0
	for lamp in harbor_street.get_children():
		if str(lamp.name).begins_with("HarborStreetLamp_"):
			var lamp_head := lamp.get_node_or_null("LampHead") as MeshInstance3D
			var lamp_material := lamp_head.material_override as StandardMaterial3D if lamp_head != null else null
			if lamp_material != null and lamp_material.emission_enabled:
				emissive_lamp_count += 1
	if emissive_lamp_count != 4:
		_fail("All four harbor street lamps must retain emissive lamp heads.")
		return
	var sidewalk_count := 0
	for child in harbor_street.get_children():
		if str(child.name).begins_with("Sidewalk_"):
			sidewalk_count += 1
	if sidewalk_count != 2:
		_fail("Both raised harbor sidewalks must be present; found %d." % sidewalk_count)
		return

	# Match the reference protagonist: white sleeveless top, blue denim and dark shoes.
	var shirt := imported_hero.find_child("HoodieBody", true, false) as MeshInstance3D
	var shirt_material := shirt.material_override as StandardMaterial3D if shirt != null else null
	if shirt_material == null or shirt_material.albedo_texture == null or shirt_material.albedo_texture.resource_path != "res://assets/characters/materials/ghibli_white_tank_fabric.svg":
		_fail("The player is missing the white cotton sleeveless-shirt material.")
		return
	for hidden_part_name in ["Hood", "HoodiePocket", "HoodieZip", "HoodieDrawstrings"]:
		var hidden_part := imported_hero.find_child(hidden_part_name, true, false) as MeshInstance3D
		if hidden_part == null or hidden_part.visible:
			_fail("The reference sleeveless outfit must hide hoodie detail: " + hidden_part_name)
			return
	for side in ["ArmPivot_Left", "ArmPivot_Right"]:
		var arm := imported_hero.find_child(side, true, false) as Node3D
		if arm == null:
			_fail("The imported hero is missing arm pivot: " + side)
			return
		for arm_clothing_name in ["HoodieSleeve", "SleeveCuff"]:
			var arm_clothing_parts := arm.find_children(arm_clothing_name + "*", "MeshInstance3D", true, false)
			if arm_clothing_parts.is_empty():
				_fail("The imported arm is missing the expected clothing mesh prefix: " + side + "/" + arm_clothing_name)
				return
			for arm_clothing in arm_clothing_parts:
				if (arm_clothing as MeshInstance3D).visible:
					_fail("The reference sleeveless outfit still shows " + side + "/" + str(arm_clothing.name))
					return
	for side in ["LegPivot_Left", "LegPivot_Right"]:
		var leg := imported_hero.find_child(side, true, false) as Node3D
		if leg == null:
			_fail("The imported hero is missing leg pivot: " + side)
			return
		var trouser_parts := leg.find_children("TrouserLeg*", "MeshInstance3D", true, false)
		if trouser_parts.is_empty():
			_fail("The imported leg is missing its trouser mesh: " + side)
			return
		for trouser_part in trouser_parts:
			var trouser_material := (trouser_part as MeshInstance3D).material_override as StandardMaterial3D
			if trouser_material == null or trouser_material.albedo_texture == null or trouser_material.albedo_texture.resource_path != "res://assets/characters/materials/ghibli_blue_denim.svg":
				_fail("The player leg is missing the blue denim material: " + side + "/" + str(trouser_part.name))
				return
		var shoe_parts := leg.find_children("SneakerUpper*", "MeshInstance3D", true, false)
		if shoe_parts.is_empty():
			_fail("The imported leg is missing its shoe upper: " + side)
			return
		for shoe_part in shoe_parts:
			var shoe_material := (shoe_part as MeshInstance3D).material_override as StandardMaterial3D
			if shoe_material == null or shoe_material.albedo_color.get_luminance() > 0.20:
				_fail("The player shoe is not using the required dark material: " + side + "/" + str(shoe_part.name))
				return

	var car_body := pbr_car.find_child("Body_Painted_Shell", true, false) as MeshInstance3D
	if car_body == null or car_body.mesh == null:
		_fail("The sports-car paint geometry was not imported.")
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
