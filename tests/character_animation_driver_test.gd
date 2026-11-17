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

	if animation_driver.get("_animation_player") == null:
		push_error("The imported free animation packs did not provide an AnimationPlayer.")
		quit(1)
		return
	var available_animations: PackedStringArray = animation_driver.call("get_available_animation_names")
	if int(animation_driver.call("get_merged_animation_count")) < 80:
		push_error("Expected the two free Standard packs to merge at least 80 complementary animation clips.")
		quit(1)
		return
	for required_clip in ["Idle_Loop", "Walk_Loop", "Jog_Fwd_Loop", "Sprint_Loop", "Driving_Loop", "TreeChopping_Loop", "Farm_Harvest", "Consume"]:
		var clip_found := false
		for clip_name in available_animations:
			if clip_name.to_lower().ends_with(required_clip.to_lower()):
				clip_found = true
				break
		if not clip_found:
			push_error("Required free Standard animation is missing: " + required_clip + ". Found: " + str(available_animations))
			quit(1)
			return

	var leg_index := skeleton.find_bone("thigh_l")
	var arm_index := skeleton.find_bone("upperarm_l")
	var rest_leg: Quaternion = skeleton.get_bone_pose_rotation(leg_index)
	var rest_arm: Quaternion = skeleton.get_bone_pose_rotation(arm_index)

	animation_driver.set("_time", 0.75)
	animation_driver.call("update_locomotion", 0.0, false, true)
	if not str(animation_driver.call("get_active_animation")).to_lower().ends_with("idle_loop"):
		push_error("The imported UAL1 idle clip was not activated.")
		quit(1)
		return
	if str(animation_driver.call("get_locomotion_state")) != "idle":
		push_error("Idle locomotion state was not selected.")
		quit(1)
		return

	animation_driver.call("update_locomotion", 2.5, false, true)
	if not str(animation_driver.call("get_active_animation")).to_lower().ends_with("walk_loop"):
		push_error("The imported UAL1 walk clip was not activated.")
		quit(1)
		return
	if str(animation_driver.call("get_locomotion_state")) != "walk":
		push_error("Walk locomotion state was not selected.")
		quit(1)
		return
	await process_frame
	await process_frame
	var walk_leg: Quaternion = skeleton.get_bone_pose_rotation(leg_index)
	if is_equal_approx(walk_leg.x, rest_leg.x) and is_equal_approx(walk_leg.y, rest_leg.y) \
			and is_equal_approx(walk_leg.z, rest_leg.z) and is_equal_approx(walk_leg.w, rest_leg.w):
		push_error("Walking did not apply a procedural leg pose to the humanoid skeleton.")
		quit(1)
		return

	animation_driver.call("update_locomotion", 7.0, true, true)
	if not str(animation_driver.call("get_active_animation")).to_lower().ends_with("sprint_loop"):
		push_error("The imported UAL1 sprint clip was not activated.")
		quit(1)
		return
	if str(animation_driver.call("get_locomotion_state")) != "run":
		push_error("Run locomotion state was not selected.")
		quit(1)
		return
	animation_driver.call("update_locomotion", 0.0, false, false)
	if not str(animation_driver.call("get_active_animation")).to_lower().ends_with("jump_loop"):
		push_error("The imported UAL1 jump/fall clip was not activated.")
		quit(1)
		return
	if str(animation_driver.call("get_locomotion_state")) != "fall":
		push_error("Fall locomotion state was not selected.")
		quit(1)
		return

	animation_driver.call("set_vehicle_state", true, &"bicycle")
	if str(animation_driver.call("get_locomotion_state")) != "bicycle":
		push_error("Bicycle pose state was not selected.")
		quit(1)
		return
	await process_frame
	await process_frame
	var bicycle_arm: Quaternion = skeleton.get_bone_pose_rotation(arm_index)
	if is_equal_approx(bicycle_arm.x, rest_arm.x) and is_equal_approx(bicycle_arm.y, rest_arm.y) \
			and is_equal_approx(bicycle_arm.z, rest_arm.z) and is_equal_approx(bicycle_arm.w, rest_arm.w):
		push_error("Bicycle pose did not move the humanoid arms toward the handlebars.")
		quit(1)
		return

	if not bool(animation_driver.call("play_named_action", &"chop")):
		push_error("The UAL2 dedicated tree-chopping animation could not be started.")
		quit(1)
		return
	if not str(animation_driver.call("get_active_animation")).to_lower().ends_with("treechopping_loop"):
		push_error("The UAL2 tree-chopping clip did not become the active animation.")
		quit(1)
		return
	if not bool(animation_driver.call("play_named_action", &"harvest")):
		push_error("The UAL2 farming-harvest action could not be started.")
		quit(1)
		return

	animation_driver.call("set_vehicle_state", true, &"car")
	if not str(animation_driver.call("get_active_animation")).to_lower().ends_with("driving_loop"):
		push_error("The imported UAL1 driving clip was not activated.")
		quit(1)
		return
	if str(animation_driver.call("get_locomotion_state")) != "car":
		push_error("Car pose state was not selected.")
		quit(1)
		return
	animation_driver.call("set_vehicle_state", false)
	if not str(animation_driver.call("get_active_animation")).to_lower().ends_with("idle_loop"):
		push_error("Leaving a vehicle did not restore the imported idle clip.")
		quit(1)
		return
	if str(animation_driver.call("get_locomotion_state")) != "idle":
		push_error("Leaving a vehicle did not restore the idle animation state.")
		quit(1)
		return

	if not is_equal_approx(float(player.get("sprint_multiplier")), 1.55):
		push_error("Player sprint multiplier is missing or has an unexpected default.")
		quit(1)
		return

	print("PASS: imported humanoid mesh, skeleton binding, procedural locomotion and vehicle pose states.")
	quit(0)
