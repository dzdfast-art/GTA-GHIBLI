extends SceneTree

func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var game := Node3D.new()
	game.name = "GameRoot"
	var main_script: Script = load("res://main.gd") as Script
	if main_script == null:
		_fail("The main game script could not be loaded.")
		return
	game.set_script(main_script)
	root.add_child(game)
	await process_frame

	var bicycle := game.get_node_or_null("StarterBicycle") as CharacterBody3D
	if bicycle == null or not bicycle.is_in_group("bicycles"):
		_fail("The starter bicycle is not present in the live world.")
		return
	if bicycle.get_node_or_null("BicycleVisuals/FrontWheel/Tire") == null \
			or bicycle.get_node_or_null("BicycleVisuals/FrontWheel/Spoke_Left_00") == null:
		_fail("The bicycle frame, tire or wheel spokes are missing.")
		return

	var player := game.get_node_or_null("Player") as CharacterBody3D
	if player == null or player.get_node_or_null("Visual/WhiteSleevelessShirt") == null \
			or player.get_node_or_null("Visual/LeftShoe") == null \
			or player.get_node_or_null("Visual/Neck") == null \
			or player.get_node_or_null("Visual/LeftHand") == null \
			or player.get_node_or_null("Visual/LeftShoe/LeftSole") == null:
		_fail("The reference character outfit, hands or footwear details are incomplete.")
		return
	var visual_animator := player.get_node("Visual") as Node3D
	var left_shoe := player.get_node("Visual/LeftShoe") as MeshInstance3D
	player.velocity = Vector3(0.0, 0.0, -5.0)
	visual_animator.call("_process", 0.10)
	if is_equal_approx(left_shoe.position.z, -0.065):
		_fail("The character's left shoe did not follow the walking gait.")
		return
	player.velocity = Vector3.ZERO
	visual_animator.call("_process", 0.10)
	if not is_equal_approx(left_shoe.position.z, -0.065):
		_fail("The character's left shoe did not return to its idle position.")
		return
	var jeans_hips := player.get_node_or_null("Visual/JeansHips") as MeshInstance3D
	var rear_belt := player.get_node_or_null("Visual/RearBelt") as MeshInstance3D
	var left_rear_pocket := player.get_node_or_null("Visual/RearPocketLeft") as MeshInstance3D
	var right_rear_pocket := player.get_node_or_null("Visual/RearPocketRight") as MeshInstance3D
	if jeans_hips == null or jeans_hips.mesh == null or rear_belt == null \
			or left_rear_pocket == null or right_rear_pocket == null:
		_fail("The character's denim hip silhouette, rear belt or jeans pockets are missing.")
		return
	if player.get_node_or_null("Visual/BeltBuckle") == null \
			or player.get_node_or_null("Visual/RearPocketStitchLeft") == null:
		_fail("The character's belt buckle or rear-pocket seam detail is missing.")
		return

	var follow_spring := player.get_node("CameraPivot/SpringArm3D") as SpringArm3D
	var follow_camera := player.get_node("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	if follow_camera == null:
		_fail("The third-person follow camera is missing.")
		return
	if not is_equal_approx(follow_spring.spring_length, 4.0) \
			or not is_equal_approx(follow_camera.fov, 67.0):
		_fail("The reference camera framing distance or field of view is not applied.")
		return

	var configured_icon := str(ProjectSettings.get_setting("application/config/icon", ""))
	var app_icon := load("res://assets/ui/gta_ghibli_app_icon.svg") as Texture2D
	if configured_icon != "res://assets/ui/gta_ghibli_app_icon.svg" or app_icon == null:
		_fail("The GTA GHIBLI application icon is not configured or imported.")
		return

	var village := game.get_node_or_null("WillowVillage") as Node3D
	if village == null or village.get_node_or_null("ReferenceResidentialRoad") == null \
			or village.get_node_or_null("ResidentialSidewalk_East") == null \
			or village.get_node_or_null("ReferenceMissionMarker/BlueMissionBeam") == null:
		_fail("The road, sidewalk or blue mission marker is missing from the opening village.")
		return

	for house_name in ["BakerHouse", "BlueHouse", "CaretakerHouse", "Workshop"]:
		var house := village.get_node_or_null(house_name) as StaticBody3D
		if house == null:
			_fail("A reference residential building is missing: " + house_name)
			return
		var wall_mesh := house.get_node_or_null("Walls") as MeshInstance3D
		var wall_material := wall_mesh.material_override as StandardMaterial3D if wall_mesh != null else null
		if wall_material == null or wall_material.albedo_texture == null:
			_fail("The textured stucco facade did not load on " + house_name)
			return
		for roof_part in ["RoofSlope_Front", "RoofSlope_Rear", "RoofRidge",
				"FrontGable", "RearGable"]:
			var roof_mesh := house.get_node_or_null(roof_part) as MeshInstance3D
			if roof_mesh == null or roof_mesh.mesh == null:
				_fail("The sloped roof component %s is missing from %s." % [roof_part, house_name])
				return
		for roof_side in ["RoofSlope_Front", "RoofSlope_Rear"]:
			var slope := house.get_node_or_null(roof_side) as MeshInstance3D
			var roof_material := slope.material_override as StandardMaterial3D if slope != null else null
			if roof_material == null or roof_material.albedo_texture == null:
				_fail("The textured terracotta roof surface did not load on %s/%s." % [house_name, roof_side])
				return
			var tile_batch := slope.get_node_or_null("RoofTileCourses") as MultiMeshInstance3D if slope != null else null
			if tile_batch == null or tile_batch.multimesh == null \
					or tile_batch.multimesh.instance_count != 78:
				_fail("The roof tile batch is missing or incomplete on %s/%s." % [house_name, roof_side])
				return

	var detailed_tree := village.get_node_or_null("WillowTree_00") as Node3D
	if detailed_tree == null:
		_fail("The detailed village tree is missing.")
		return
	var foliage_cluster_count := 0
	for child in detailed_tree.get_children():
		if child is MeshInstance3D and child.name.begins_with("FoliageCluster_"):
			foliage_cluster_count += 1
	var textured_trunk := detailed_tree.get_node_or_null("TexturedTrunk") as MeshInstance3D
	var bark_material: StandardMaterial3D = null
	if textured_trunk != null:
		bark_material = textured_trunk.material_override as StandardMaterial3D
	var first_foliage_cluster := detailed_tree.get_node_or_null("FoliageCluster_00") as MeshInstance3D
	var foliage_material: StandardMaterial3D = null
	if first_foliage_cluster != null:
		foliage_material = first_foliage_cluster.material_override as StandardMaterial3D
	var has_detailed_tree_materials := foliage_cluster_count >= 9
	has_detailed_tree_materials = has_detailed_tree_materials and bark_material != null
	has_detailed_tree_materials = has_detailed_tree_materials and bark_material.albedo_texture != null
	has_detailed_tree_materials = has_detailed_tree_materials and foliage_material != null
	has_detailed_tree_materials = has_detailed_tree_materials and foliage_material.albedo_texture != null
	if not has_detailed_tree_materials:
		_fail("The detailed foliage clusters or textured bark/leaf materials did not load.")
		return
	var street_tree := village.get_node_or_null("ResidentialTree_00_W") as Node3D
	if street_tree == null or street_tree.get_node_or_null("FoliageCluster_08") == null:
		_fail("The reference street is not using the upgraded layered tree assets.")
		return

	var roadside_grass := village.get_node_or_null("RoadsideGrass_East") as MultiMeshInstance3D
	if roadside_grass == null or roadside_grass.multimesh == null \
			or roadside_grass.multimesh.instance_count != 84:
		_fail("The instanced roadside ground-cover detail is missing or incomplete.")
		return

	var controls := game.get_node_or_null("MobileControls")
	if controls == null or controls.get_node_or_null("HUD/Minimap") == null \
			or controls.get_node_or_null("HUD/StatusPanel") == null:
		_fail("The reference mobile minimap or status HUD is missing.")
		return

	var portal := game.get_node_or_null("WillowVillage/CaretakerHousePortal") as Node3D
	if portal == null or not portal.is_in_group("building_portals"):
		_fail("The caretaker house portal is not connected to Willow Village.")
		return
	var exterior_entry := portal.get_node_or_null("ExteriorEntry") as Area3D
	if exterior_entry == null or not exterior_entry.is_in_group("interaction_areas"):
		_fail("The house portal exterior interaction area is missing.")
		return

	var bridge := game.get_node_or_null("OpenWorldRegions/AmberValley/RedBridgeLandmark") as StaticBody3D
	if bridge == null or not bridge.is_in_group("world_landmarks"):
		_fail("The red bridge is not connected to the Amber Valley district.")
		return
	var bridge_mesh := bridge.get_node_or_null("BridgeMesh") as MeshInstance3D
	if bridge_mesh == null or bridge_mesh.mesh == null:
		_fail("The original red bridge mesh did not load.")
		return
	var ravine := bridge.get_node_or_null("RavineBackdrop") as MeshInstance3D
	if ravine == null or ravine.mesh == null:
		_fail("The red bridge ravine terrain mesh did not load.")
		return
	var deck := bridge.get_node_or_null("DeckCollision") as CollisionShape3D
	if deck == null or not (deck.shape is BoxShape3D):
		_fail("The bridge deck collision shape is missing.")
		return

	print("PASS: reference character, third-person camera, street, blue marker, mobile HUD, rideable bicycle, house portal, red bridge and walkable deck are present.")
	game.queue_free()
	await process_frame
	await process_frame
	# Clear every borrowed Node/Resource reference before the strict leak check.
	bicycle = null
	player = null
	visual_animator = null
	left_shoe = null
	village = null
	controls = null
	portal = null
	exterior_entry = null
	bridge = null
	bridge_mesh = null
	ravine = null
	deck = null
	game = null
	main_script = null
	await process_frame
	await process_frame
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
