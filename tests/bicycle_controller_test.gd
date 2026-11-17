extends SceneTree

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const BICYCLE_SCENE: PackedScene = preload("res://scenes/vehicles/starter_bicycle.tscn")
const MOBILE_CONTROLS_SCRIPT = preload("res://scripts/ui/mobile_controls.gd")


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var floor_body := StaticBody3D.new()
	root.add_child(floor_body)
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(80.0, 1.0, 120.0)
	var floor_collision := CollisionShape3D.new()
	floor_collision.shape = floor_shape
	floor_collision.position.y = -0.5
	floor_body.add_child(floor_collision)

	var player := PLAYER_SCENE.instantiate() as CharacterBody3D
	player.name = "Player"
	player.add_to_group("player")
	player.position = Vector3(0.0, 0.95, 0.0)
	root.add_child(player)

	var controls: CanvasLayer = MOBILE_CONTROLS_SCRIPT.new() as CanvasLayer
	root.add_child(controls)

	var bicycle := BICYCLE_SCENE.instantiate() as CharacterBody3D
	bicycle.position = Vector3(0.0, 0.0, 1.6)
	bicycle.rotation.y = PI
	root.add_child(bicycle)

	await process_frame
	await process_frame
	for _frame in range(4):
		await physics_frame

	bicycle.call("interact")
	if bicycle.get("driver") != player or not bool(player.get("is_driving")):
		_fail("The player could not mount the bicycle.")
		return
	if player.collision_layer != 0 or player.collision_mask != 0:
		_fail("Player collision was not disabled while riding.")
		return
	if not (controls.get_node("HUD/BikePedal") as Control).visible:
		_fail("The bicycle pedal control was not shown.")
		return

	# The current mobile HUD uses an exit icon plus an Arabic tooltip, not legacy button text.
	var contextual_exit := controls.get_node("HUD/ContextAction") as Button
	if contextual_exit == null or contextual_exit.icon == null or not contextual_exit.text.is_empty() \
			or contextual_exit.tooltip_text != "النزول من الدراجة":
		_fail("The contextual exit-bike icon and Arabic hint were not shown.")
		return
	contextual_exit.emit_signal("button_down")
	if not Input.is_action_pressed("interact"):
		_fail("The contextual exit-bike button did not press the interact action.")
		return
	# Let the real player interactor consume the press before releasing it.
	await process_frame
	await process_frame
	if bicycle.get("driver") != null or bool(player.get("is_driving")):
		_fail("The contextual exit-bike button did not dismount the player.")
		return
	contextual_exit.emit_signal("button_up")
	if Input.is_action_pressed("interact"):
		_fail("Releasing the contextual exit-bike button left interact pressed.")
		return
	var on_foot_hints := ["التفاعل", "تفاعل", "اركب الدراجة"]
	if contextual_exit.icon == null \
			or contextual_exit.icon.resource_path != "res://assets/ui/hud/interact.svg" \
			or not on_foot_hints.has(contextual_exit.tooltip_text):
		_fail("The on-foot contextual interaction icon and context-sensitive hint were not restored.")
		return

	# Remount after validating the real exit action, then test riding physics separately.
	bicycle.call("interact")
	await process_frame
	await physics_frame
	if bicycle.get("driver") != player or not bool(player.get("is_driving")):
		_fail("The player could not remount after using the contextual exit action.")
		return

	var start_position: Vector3 = bicycle.global_position
	var forward_before: Vector3 = -bicycle.global_basis.z.normalized()
	Input.action_press("bike_pedal")
	var pedal_action_seen := Input.is_action_pressed("bike_pedal")
	var max_observed_speed := 0.0
	for _frame in range(36):
		await physics_frame
		max_observed_speed = maxf(max_observed_speed, absf(float(bicycle.get("_speed"))))
	Input.action_release("bike_pedal")
	var end_position: Vector3 = bicycle.global_position
	var travelled_forward := (end_position - start_position).dot(forward_before)
	print("BIKE_DIAGNOSTIC pedal_action=%s start=%s end=%s forward=%s travelled=%f speed=%f max_speed=%f velocity=%s real_velocity=%s grounded=%s driver_valid=%s" % [
		str(pedal_action_seen), str(start_position), str(end_position), str(forward_before),
		travelled_forward, float(bicycle.get("_speed")), max_observed_speed,
		str(bicycle.velocity), str(bicycle.get_real_velocity()), str(bicycle.is_on_floor()),
		str(is_instance_valid(bicycle.get("driver")))])
	if not pedal_action_seen or max_observed_speed < 0.2 or travelled_forward <= 0.25:
		_fail("Pedaling did not move the bicycle forward along its facing direction.")
		return

	var start_rotation: float = bicycle.rotation.y
	Input.action_press("bike_steer_right")
	Input.action_press("bike_pedal")
	for _frame in range(24):
		await physics_frame
	Input.action_release("bike_steer_right")
	Input.action_release("bike_pedal")
	if is_equal_approx(bicycle.rotation.y, start_rotation):
		_fail("Bicycle steering did not change its heading.")
		return

	Input.action_press("bike_brake")
	var reversed := false
	for _frame in range(60):
		await physics_frame
		if float(bicycle.get("_speed")) < -0.1:
			reversed = true
			break
	Input.action_release("bike_brake")
	if not reversed:
		_fail("Holding brake at low speed did not provide reverse movement.")
		return

	controls.call("set_bike_steering_mode", "buttons")
	if (controls.get_node("HUD/MovementJoystick") as Control).visible:
		_fail("Buttons mode should hide the analog joystick while cycling.")
		return
	if not (controls.get_node("HUD/BikeSteerLeft") as Control).visible:
		_fail("Buttons mode did not show dedicated left/right steering buttons.")
		return
	controls.call("set_bike_steering_mode", "flick")
	if (controls.get_node("HUD/BikeSteerLeft") as Control).visible:
		_fail("Flick mode should hide the dedicated steering buttons.")
		return
	controls.call("set_bike_steering_mode", "analog")
	if not (controls.get_node("HUD/MovementJoystick") as Control).visible:
		_fail("Analog mode did not restore the steering joystick.")
		return

	bicycle.call("interact")
	if bicycle.get("driver") != null or bool(player.get("is_driving")):
		_fail("The player could not dismount the bicycle.")
		return
	if player.collision_layer == 0 or player.collision_mask == 0:
		_fail("Player collision settings were not restored after dismounting.")
		return
	if not bool(player.get_node("Visual").visible):
		_fail("The player model was not restored after dismounting.")
		return
	if not (controls.get_node("HUD/Sprint") as Control).visible:
		_fail("The on-foot RUN control was not restored after dismounting.")
		return
	print("PASS: bicycle mount, contextual exit action, pedal, steering, brake/reverse, steering layouts, and dismount.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
