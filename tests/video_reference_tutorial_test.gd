extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := MAIN_SCENE.instantiate()
	root.add_child(game)
	for _frame in range(8):
		await process_frame

	var player := game.get_node_or_null("Player") as CharacterBody3D
	var bicycle := game.get_node_or_null("StarterBicycle") as CharacterBody3D
	var tutorial := game.get_node_or_null("VideoReferenceTutorial")
	var bridge := get_first_node_in_group("world_landmarks") as Node3D
	var portal := game.get_node_or_null("WillowVillage/CaretakerHousePortal")
	if player == null or bicycle == null or tutorial == null or bridge == null or portal == null:
		_fail("The tutorial must bind the live player, bicycle, red bridge and caretaker house.")
		return

	if tutorial.call("get_stage_id") != "mount_bike":
		_fail("The opening tutorial stage should direct the player to mount the nearby bicycle.")
		return
	if bicycle.get_node_or_null("VideoReferenceBlueMarker") == null:
		_fail("The bicycle must display the blue tutorial marker.")
		return
	if str(tutorial.call("get_objective_text")).is_empty():
		_fail("The tutorial objective text must be visible.")
		return
	var hud := game.get_node_or_null("MobileControls/GameplayHUD") as Control
	if hud == null or hud.get_node_or_null("TutorialObjective") == null:
		_fail("The route objective must be displayed by the gameplay HUD.")
		return
	if not (hud.get_node("TutorialObjective") as Label).visible:
		_fail("The first route objective should be visible at game start.")
		return

	bicycle.call("interact")
	for _frame in range(3):
		await process_frame
	if tutorial.call("get_stage_id") != "ride_to_bridge":
		_fail("Mounting the bicycle must advance the tutorial to the red bridge.")
		return

	bicycle.global_position = bridge.global_position
	for _frame in range(4):
		await process_frame
	if tutorial.call("get_stage_id") != "dismount_at_bridge":
		_fail("Reaching the red bridge must ask the player to dismount.")
		return

	bicycle.call("interact")
	player.global_position = portal.global_position + Vector3(0.0, 0.0, 1.5)
	for _frame in range(4):
		await process_frame
	if tutorial.call("get_stage_id") != "enter_house":
		_fail("After dismounting, the tutorial must guide the player to the house.")
		return

	portal.call("interact")
	for _frame in range(4):
		await process_frame
	if tutorial.call("get_stage_id") != "complete":
		_fail("Entering the marked house must complete the video-reference tutorial.")
		return

	print("PASS: blue bike marker, bicycle mount, red bridge, dismount and house-entry tutorial.")
	game.queue_free()
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
