extends SceneTree

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PLAYER_SCENE.instantiate() as CharacterBody3D
	if player == null:
		push_error("Player scene could not be instantiated.")
		quit(1)
		return
	root.add_child(player)
	await process_frame

	var animation_driver := player.get_node_or_null("CharacterAnimationDriver")
	if animation_driver == null:
		push_error("CharacterAnimationDriver is missing from the player scene.")
		quit(1)
		return

	# These calls must remain safe while the temporary capsule has no rig or clips.
	animation_driver.call("update_locomotion", 0.0, false, true)
	animation_driver.call("update_locomotion", 2.5, false, true)
	animation_driver.call("update_locomotion", 7.0, true, true)
	animation_driver.call("update_locomotion", 0.0, false, false)
	animation_driver.call("set_vehicle_state", true, &"bicycle")
	animation_driver.call("set_vehicle_state", true, &"car")
	animation_driver.call("set_vehicle_state", false)

	if not is_equal_approx(float(player.get("sprint_multiplier")), 1.55):
		push_error("Player sprint multiplier is missing or has an unexpected default.")
		quit(1)
		return

	print("PASS: animation state adapter handles idle, walk, run, fall and vehicle states without requiring a rig.")
	quit(0)
