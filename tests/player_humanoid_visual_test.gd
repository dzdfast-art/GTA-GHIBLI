extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := MAIN_SCENE.instantiate()
	root.add_child(game)
	for _frame in range(6):
		await process_frame

	var player := game.get_node_or_null("Player") as CharacterBody3D
	var visual := player.get_node_or_null("Visual") as Node3D if player != null else null
	if visual == null:
		_fail("The player visual must be a Node3D character rig root.")
		return
	for part in ["Head", "Hair", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"]:
		if visual.get_node_or_null(part) == null:
			_fail("The humanoid character is missing body part: " + part)
			return
	if visual.get_node_or_null("LeftLeg/Shoe") == null or visual.get_node_or_null("RightLeg/Shoe") == null:
		_fail("The humanoid character must include two visible dark shoes.")
		return
	if visual.get_node_or_null("Torso/Shirt") == null:
		_fail("The character must wear the original white sleeveless shirt.")
		return
	if visual.get_node_or_null("LeftLeg/Pants") == null:
		_fail("The character must wear blue pants.")
		return
	if not visual.has_method("get_locomotion_weight"):
		_fail("The humanoid rig must expose its current locomotion animation weight.")
		return
	if float(visual.call("get_locomotion_weight")) < 0.0:
		_fail("Locomotion animation weight must never be negative.")
		return

	print("PASS: original humanoid model, white sleeveless shirt, blue pants and shoes.")
	game.queue_free()
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
