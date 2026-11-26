extends SceneTree

func _initialize() -> void:
	call_deferred("_run_smoke_test")


func _run_smoke_test() -> void:
	var packed_scene := load("res://main.tscn") as PackedScene
	if packed_scene == null:
		_fail("The main scene could not be loaded as a PackedScene.")
		return

	var game := packed_scene.instantiate() as Node3D
	if game == null:
		_fail("The main scene root is not a Node3D instance.")
		return
	root.add_child(game)
	await process_frame

	var failure := _validate_main_scene(game)
	if not failure.is_empty():
		game.free()
		game = null
		packed_scene = null
		await process_frame
		_fail(failure)
		return

	print("PASS: main.tscn instantiates the player, camera, reference street, blue marker, vehicles, mobile HUD, world systems and textured four-house village.")

	# Release the scene synchronously, after all validation references have left
	# _validate_main_scene(), so no local Node or Resource references survive exit.
	game.free()
	game = null
	packed_scene = null
	await process_frame
	await process_frame
	quit(0)


func _validate_main_scene(game: Node3D) -> String:
	var required_paths := [
		"Player",
		"Player/CameraPivot/SpringArm3D/Camera3D",
		"WillowVillage/ReferenceResidentialRoad",
		"WillowVillage/ReferenceMissionMarker/BlueMissionBeam",
		"StarterCar",
		"StarterBicycle",
		"MobileControls/HUD/Minimap",
		"MobileControls/HUD/StatusPanel",
		"WorldClock",
		"OpenWorldRegions/AmberValley/RedBridgeLandmark"
	]
	var missing_paths: Array[String] = []
	for required_path in required_paths:
		if game.get_node_or_null(required_path) == null:
			missing_paths.append(required_path)
	if not missing_paths.is_empty():
		return "Main scene is missing required gameplay nodes: " + str(missing_paths)

	var configured_icon := str(ProjectSettings.get_setting("application/config/icon", ""))
	var app_icon := load("res://assets/ui/gta_ghibli_app_icon.svg") as Texture2D
	if configured_icon != "res://assets/ui/gta_ghibli_app_icon.svg" or app_icon == null:
		return "The GTA GHIBLI application icon is not configured or imported."

	var village := game.get_node("WillowVillage") as Node3D
	for house_name in ["BakerHouse", "BlueHouse", "CaretakerHouse", "Workshop"]:
		var house := village.get_node_or_null(house_name) as StaticBody3D
		if house == null:
			return "A reference residential building is missing: " + house_name
		var wall_mesh := house.get_node_or_null("Walls") as MeshInstance3D
		var wall_material := wall_mesh.material_override as StandardMaterial3D if wall_mesh != null else null
		if wall_material == null or wall_material.albedo_texture == null:
			return "Main scene facade texture did not initialize for " + house_name
		for side in ["Front", "Rear"]:
			var slope := house.get_node_or_null("RoofSlope_" + side) as MeshInstance3D
			var roof_material := slope.material_override as StandardMaterial3D if slope != null else null
			if roof_material == null or roof_material.albedo_texture == null:
				return "Main scene roof texture did not initialize for %s/%s." % [house_name, side]
	return ""


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
