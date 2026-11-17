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
	if not bool(player.get_node("Visual").visible):
		_fail("The humanoid rider was hidden while mounted on the bicycle.")
		return
	if not (controls.get_node("HUD/BikePedal") as Control).visible:
		_fail("The bicycle pedal control was not shown.")
		return
	if controls.get_node("HUD/ContextAction").text != "EXIT BIKE":
		_fail("The contextual exit-bike action was not shown.")
		return

	var start_z: float = bicycle.global_position.z
	Input.action_press("bike_pedal")
	for _frame in range(36):
		await physics_frame
	Input.action_release("bike_pedal")
	if bicycle.global_position.z <= start_z + 0.25:
		_fail("Pedaling did not move the bicycle forward.")
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

	print("PASS: bicycle mount, pedal, steering, brake/reverse, steering layouts, and dismount.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
