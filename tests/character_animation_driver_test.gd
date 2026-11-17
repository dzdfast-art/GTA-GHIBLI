extends SceneTree

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _find_skeleton(node: Node) -> Skeleton3D:
	for child in node.get_children():
		var skeleton := child as Skeleton3D
		if skeleton != null:
			return skeleton
		var nested := _find_skeleton(child)
		if nested != null:
			return nested
	return null


func _run() -> void:
	var player := PLAYER_SCENE.instantiate() as CharacterBody3D
	if player == null:
		push_error("Player scene could not be instantiated.")
		quit(1)
		return
	root.add_child(player)
	await process_frame
	await process_frame

	var visual := player.get_node_or_null("Visual") as Node3D
	if visual == null or visual.get_child_count() == 0:
		push_error("Imported humanoid visual is missing.")
		quit(1)
		return

	var skeleton := _find_skeleton(visual)
	if skeleton == null:
		push_error("Imported character GLB did not expose a Skeleton3D.")
		quit(1)
		return

	for bone_name in ["pelvis", "spine_01", "Head", "upperarm_l", "upperarm_r", "thigh_l", "thigh_r"]:
		if skeleton.find_bone(bone_name) < 0:
			push_error("Required humanoid bone is missing: " + bone_name)
			quit(1)
			return

	var animation_driver := player.get_node_or_null("CharacterAnimationDriver")
	if animation_driver == null or not bool(animation_driver.call("has_humanoid_skeleton")):
		push_error("CharacterAnimationDriver did not bind the imported humanoid skeleton.")
		quit(1)
		return

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

	print("PASS: imported humanoid mesh, skeleton binding, procedural locomotion and vehicle pose states.")
	quit(0)
