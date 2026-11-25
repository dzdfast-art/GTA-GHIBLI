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

	print("PASS: live world contains the rideable bicycle, caretaker house portal, red bridge mesh, ravine backdrop, and walkable deck collision.")
	game.queue_free()
	await process_frame
	await process_frame
	game = null
	main_script = null
	await process_frame
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
