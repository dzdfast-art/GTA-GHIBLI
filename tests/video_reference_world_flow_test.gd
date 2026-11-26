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

	var failure := _validate_reference_world(game)
	if not failure.is_empty():
		game.free()
		game = null
		main_script = null
		await process_frame
		_fail(failure)
		return

	print("PASS: reference character, third-person camera, street, blue marker, mobile HUD, rideable bicycle, house portal, red bridge and walkable deck are present.")
	# Validation references are scoped to _validate_reference_world() and have
	# been released before the world is destroyed. Allow AudioServer one mix
	# window to retire any stopped voices before the strict shutdown audit.
	game.free()
	game = null
	main_script = null
	await create_timer(0.5).timeout
	await process_frame
	await process_frame
	quit(0)


func _validate_reference_world(game: Node3D) -> String:
	var bicycle := game.get_node_or_null("StarterBicycle") as CharacterBody3D
	if bicycle == null or not bicycle.is_in_group("bicycles"):
		return "The starter bicycle is not present in the live world."
	if bicycle.get_node_or_null("BicycleVisuals/FrontWheel/Tire") == null \
			or bicycle.get_node_or_null("BicycleVisuals/FrontWheel/Spoke_Left_00") == null:
		return "The bicycle frame, tire or wheel spokes are missing."

	var player := game.get_node_or_null("Player") as CharacterBody3D
	if player == null or player.get_node_or_null("Visual/WhiteSleevelessShirt") == null \
			or player.get_node_or_null("Visual/LeftShoe") == null \
			or player.get_node_or_null("Visual/Neck") == null \
			or player.get_node_or_null("Visual/LeftHand") == null \
			or player.get_node_or_null("Visual/LeftShoe/LeftSole") == null:
		return "The reference character outfit, hands or footwear details are incomplete."
	var visual_animator := player.get_node("Visual") as Node3D
	var left_shoe := player.get_node("Visual/LeftShoe") as MeshInstance3D
	player.velocity = Vector3(0.0, 0.0, -5.0)
	visual_animator.call("_process", 0.10)
	if is_equal_approx(left_shoe.position.z, -0.065):
		return "The character's left shoe did not follow the walking gait."
	player.velocity = Vector3.ZERO
	visual_animator.call("_process", 0.10)
	if not is_equal_approx(left_shoe.position.z, -0.065):
		return "The character's left shoe did not return to its idle position."
	var jeans_hips := player.get_node_or_null("Visual/JeansHips") as MeshInstance3D
	var rear_belt := player.get_node_or_null("Visual/RearBelt") as MeshInstance3D
	var left_rear_pocket := player.get_node_or_null("Visual/RearPocketLeft") as MeshInstance3D
	var right_rear_pocket := player.get_node_or_null("Visual/RearPocketRight") as MeshInstance3D
	if jeans_hips == null or jeans_hips.mesh == null or rear_belt == null \
			or left_rear_pocket == null or right_rear_pocket == null:
		return "The character's denim hip silhouette, rear belt or jeans pockets are missing."
	if player.get_node_or_null("Visual/BeltBuckle") == null \
			or player.get_node_or_null("Visual/RearPocketStitchLeft") == null:
		return "The character's belt buckle or rear-pocket seam detail is missing."

	var follow_spring := player.get_node("CameraPivot/SpringArm3D") as SpringArm3D
	var follow_camera := player.get_node("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	if follow_camera == null:
		return "The third-person follow camera is missing."
	if not is_equal_approx(follow_spring.spring_length, 4.0) \
			or not is_equal_approx(follow_camera.fov, 67.0):
		return "The reference camera framing distance or field of view is not applied."

	var configured_icon := str(ProjectSettings.get_setting("application/config/icon", ""))
	var app_icon := load("res://assets/ui/gta_ghibli_app_icon.svg") as Texture2D
	if configured_icon != "res://assets/ui/gta_ghibli_app_icon.svg" or app_icon == null:
		return "The GTA GHIBLI application icon is not configured or imported."

	var village := game.get_node_or_null("WillowVillage") as Node3D
	if village == null or village.get_node_or_null("ReferenceResidentialRoad") == null \
			or village.get_node_or_null("ResidentialSidewalk_East") == null \
			or village.get_node_or_null("ReferenceMissionMarker/BlueMissionBeam") == null:
		return "The road, sidewalk or blue mission marker is missing from the opening village."

	for house_name in ["BakerHouse", "BlueHouse", "CaretakerHouse", "Workshop"]:
		var house := village.get_node_or_null(house_name) as StaticBody3D
		if house == null:
			return "A reference residential building is missing: " + house_name
		var wall_mesh := house.get_node_or_null("Walls") as MeshInstance3D
		var wall_material := wall_mesh.material_override as StandardMaterial3D if wall_mesh != null else null
		if wall_material == null or wall_material.albedo_texture == null:
			return "The textured stucco facade did not load on " + house_name
		for roof_part in ["RoofSlope_Front", "RoofSlope_Rear", "RoofRidge",
				"FrontGable", "RearGable"]:
			var roof_mesh := house.get_node_or_null(roof_part) as MeshInstance3D
			if roof_mesh == null or roof_mesh.mesh == null:
				return "The sloped roof component %s is missing from %s." % [roof_part, house_name]
		for roof_side in ["RoofSlope_Front", "RoofSlope_Rear"]:
			var slope := house.get_node_or_null(roof_side) as MeshInstance3D
			var roof_material := slope.material_override as StandardMaterial3D if slope != null else null
			if roof_material == null or roof_material.albedo_texture == null:
				return "The textured terracotta roof surface did not load on %s/%s." % [house_name, roof_side]
			var tile_batch := slope.get_node_or_null("RoofTileCourses") as MultiMeshInstance3D if slope != null else null
			if tile_batch == null or tile_batch.multimesh == null \
					or tile_batch.multimesh.instance_count != 78:
				return "The roof tile batch is missing or incomplete on %s/%s." % [house_name, roof_side]

	var detailed_tree := village.get_node_or_null("WillowTree_00") as Node3D
	if detailed_tree == null:
		return "The detailed village tree is missing."
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
		return "The detailed foliage clusters or textured bark/leaf materials did not load."
	var street_tree := village.get_node_or_null("ResidentialTree_00_W") as Node3D
	if street_tree == null or street_tree.get_node_or_null("FoliageCluster_08") == null:
		return "The reference street is not using the upgraded layered tree assets."

	var roadside_grass := village.get_node_or_null("RoadsideGrass_East") as MultiMeshInstance3D
	if roadside_grass == null or roadside_grass.multimesh == null \
			or roadside_grass.multimesh.instance_count != 84:
		return "The instanced roadside ground-cover detail is missing or incomplete."


	var village_life := village.get_node_or_null("VillageLifeDetails") as Node3D
	if village_life == null:
		return "The village public-space visual builder did not run."
	var paving := village_life.get_node_or_null("VillageSquarePaving") as MeshInstance3D
	var paving_material := paving.material_override as StandardMaterial3D if paving != null else null
	if paving_material == null or paving_material.albedo_texture == null:
		return "The square paving atlas did not load on the plaza surface."
	for bench_name in ["VillageBench_00", "VillageBench_01"]:
		var bench := village_life.get_node_or_null(bench_name) as StaticBody3D
		if bench == null or bench.get_node_or_null("SeatPlank_00") == null \
				or bench.get_node_or_null("BenchCollision") == null:
			return "A collidable public-space bench is missing or incomplete: " + bench_name
	if village_life.get_node_or_null("VillageWasteBin_00/BinBody") == null:
		return "The village square waste bin is missing."

	var grocery := village.get_node_or_null("VillageGrocery") as Node3D
	if grocery == null:
		return "The interactive village grocery stall is missing."
	var grocery_counter := grocery.get_node_or_null("GroceryCounter") as MeshInstance3D
	var counter_material := grocery_counter.material_override as StandardMaterial3D if grocery_counter != null else null
	var grocery_awning := grocery.get_node_or_null("GroceryAwning") as MeshInstance3D
	var awning_material := grocery_awning.material_override as StandardMaterial3D if grocery_awning != null else null
	if counter_material == null or counter_material.albedo_texture == null:
		return "The market counter did not load its wood material."
	if awning_material == null or awning_material.albedo_texture == null:
		return "The market canopy did not load its woven canvas material."
	for crate_index in range(3):
		var crate := grocery.get_node_or_null("ProduceCrate_%02d" % crate_index) as Node3D
		var fruit_batch := crate.get_node_or_null("FruitBatch") as MultiMeshInstance3D if crate != null else null
		if fruit_batch == null or fruit_batch.multimesh == null \
				or fruit_batch.multimesh.instance_count != 6:
			return "A market produce display is missing or incomplete: crate %d" % crate_index
	if grocery.get_node_or_null("MarketBarrel/BarrelBody") == null \
			or grocery.get_node_or_null("GroceryChalkboard") == null \
			or grocery.get_node_or_null("ArabicMarketList") == null:
		return "The market barrel or Arabic chalkboard display is missing."


	var well_details := village_life.get_node_or_null("VillageWellEnhancement") as Node3D
	if well_details == null or well_details.get_node_or_null("TexturedStoneCoping") == null \
			or well_details.get_node_or_null("WellWater") == null:
		return "The enhanced village well stone coping or visible water surface is missing."
	var well_frame := well_details.get_node_or_null("TimberFrame") as StaticBody3D
	if well_frame == null or well_frame.get_node_or_null("PulleyWheel") == null \
			or well_frame.get_node_or_null("WellRope") == null \
			or well_frame.get_node_or_null("WaterBucket") == null:
		return "The village well pulley, rope or bucket assembly is incomplete."
	for collision_name in ["TimberPostCollision_Left", "TimberPostCollision_Right",
			"PulleyCrossbeamCollision", "RoofCollision_Left", "RoofCollision_Right"]:
		var frame_collision := well_frame.get_node_or_null(collision_name) as CollisionShape3D
		if frame_collision == null or frame_collision.shape == null:
			return "A collision shape is missing from the covered well frame: " + collision_name
	for roof_name in ["RoofSlope_Left", "RoofSlope_Right"]:
		var roof_panel := well_frame.get_node_or_null(roof_name) as MeshInstance3D
		var shingle_batch := roof_panel.get_node_or_null("TerracottaShingles") as MultiMeshInstance3D if roof_panel != null else null
		if shingle_batch == null or shingle_batch.multimesh == null \
				or shingle_batch.multimesh.instance_count != 15:
			return "A well roof slope is missing its instanced terracotta shingles: " + roof_name

	var controls := game.get_node_or_null("MobileControls")
	if controls == null or controls.get_node_or_null("HUD/Minimap") == null \
			or controls.get_node_or_null("HUD/StatusPanel") == null:
		return "The reference mobile minimap or status HUD is missing."

	var portal := game.get_node_or_null("WillowVillage/CaretakerHousePortal") as Node3D
	if portal == null or not portal.is_in_group("building_portals"):
		return "The caretaker house portal is not connected to Willow Village."
	var exterior_entry := portal.get_node_or_null("ExteriorEntry") as Area3D
	if exterior_entry == null or not exterior_entry.is_in_group("interaction_areas"):
		return "The house portal exterior interaction area is missing."

	var bridge := game.get_node_or_null("OpenWorldRegions/AmberValley/RedBridgeLandmark") as StaticBody3D
	if bridge == null or not bridge.is_in_group("world_landmarks"):
		return "The red bridge is not connected to the Amber Valley district."
	var bridge_mesh := bridge.get_node_or_null("BridgeMesh") as MeshInstance3D
	if bridge_mesh == null or bridge_mesh.mesh == null:
		return "The original red bridge mesh did not load."
	var ravine := bridge.get_node_or_null("RavineBackdrop") as MeshInstance3D
	if ravine == null or ravine.mesh == null:
		return "The red bridge ravine terrain mesh did not load."
	var deck := bridge.get_node_or_null("DeckCollision") as CollisionShape3D
	if deck == null or not (deck.shape is BoxShape3D):
		return "The bridge deck collision shape is missing."

	return ""


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
