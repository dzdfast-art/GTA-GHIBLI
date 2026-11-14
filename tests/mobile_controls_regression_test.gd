extends SceneTree

## Headless regression tests for touch ownership, camera isolation, and player motion.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const MOBILE_CONTROLS_SCRIPT = preload("res://scripts/ui/mobile_controls.gd")


func _initialize() -> void:
	call_deferred("_run_mobile_controls_test")


func _run_mobile_controls_test() -> void:
	var world := Node3D.new()
	root.add_child(world)

	var floor_body := StaticBody3D.new()
	world.add_child(floor_body)
	var floor_collision := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(40.0, 1.0, 40.0)
	floor_collision.shape = floor_shape
	floor_collision.position.y = -0.5
	floor_body.add_child(floor_collision)

	var player := PLAYER_SCENE.instantiate() as CharacterBody3D
	player.position = Vector3(0.0, 0.95, 0.0)
	world.add_child(player)

	var controls: CanvasLayer = MOBILE_CONTROLS_SCRIPT.new() as CanvasLayer
	world.add_child(controls)
	await process_frame
	await process_frame

	var joystick := controls.get_node("HUD/MovementJoystick") as Control
	if joystick.size.x < 100.0 or joystick.size.y < 100.0:
		_fail("The on-screen joystick did not receive a usable layout size.")
		return

	var joystick_center: Vector2 = joystick.get_global_transform_with_canvas() * (joystick.size * 0.5)
	var touch := InputEventScreenTouch.new()
	touch.index = 41
	touch.pressed = true
	touch.position = joystick_center
	joystick.call("_input", touch)

	var drag := InputEventScreenDrag.new()
	drag.index = 41
	drag.position = joystick_center + Vector2(0.0, -55.0)
	drag.relative = Vector2(0.0, -55.0)
	joystick.call("_input", drag)
	if not Input.is_action_pressed("ui_up"):
		_fail("Dragging the joystick upward did not press ui_up.")
		return

	# Holding the virtual joystick must move the actual CharacterBody3D.
	var start_position: Vector3 = player.global_position
	for frame_index in range(24):
		await physics_frame
	if player.global_position.distance_to(start_position) < 0.15:
		_fail("The player did not move while the virtual joystick was held.")
		return

	var release := InputEventScreenTouch.new()
	release.index = 41
	release.pressed = false
	release.position = drag.position
	joystick.call("_input", release)
	if Input.is_action_pressed("ui_up"):
		_fail("Releasing the joystick left ui_up stuck in the pressed state.")
		return

	# A left-side touch belongs to the joystick area and must not rotate the camera.
	var camera_pivot := player.get_node("CameraPivot") as Node3D
	var initial_camera_rotation: Vector3 = camera_pivot.rotation
	camera_pivot.call("_unhandled_input", touch)
	var left_drag := InputEventScreenDrag.new()
	left_drag.index = 42
	left_drag.position = joystick_center + Vector2(45.0, 0.0)
	left_drag.relative = Vector2(45.0, 0.0)
	camera_pivot.call("_unhandled_input", left_drag)
	if not camera_pivot.rotation.is_equal_approx(initial_camera_rotation):
		_fail("A left-side joystick touch unexpectedly rotated the camera.")
		return

	var viewport_size: Vector2 = get_root().get_viewport().get_visible_rect().size

	# The middle band is deliberately reserved: it must not start camera-look.
	var middle_touch := InputEventScreenTouch.new()
	middle_touch.index = 44
	middle_touch.pressed = true
	middle_touch.position = Vector2(viewport_size.x * 0.68, viewport_size.y * 0.5)
	camera_pivot.call("_unhandled_input", middle_touch)
	var middle_drag := InputEventScreenDrag.new()
	middle_drag.index = 44
	middle_drag.position = middle_touch.position + Vector2(35.0, 0.0)
	middle_drag.relative = Vector2(35.0, 0.0)
	camera_pivot.call("_unhandled_input", middle_drag)
	if not camera_pivot.rotation.is_equal_approx(initial_camera_rotation):
		_fail("A touch in the reserved middle band unexpectedly rotated the camera.")
		return

	# A right-side touch must still be able to control the camera.
	var right_touch := InputEventScreenTouch.new()
	right_touch.index = 43
	right_touch.pressed = true
	right_touch.position = Vector2(viewport_size.x * 0.82, viewport_size.y * 0.5)
	camera_pivot.call("_unhandled_input", right_touch)
	var right_drag := InputEventScreenDrag.new()
	right_drag.index = 43
	right_drag.position = right_touch.position + Vector2(35.0, 12.0)
	right_drag.relative = Vector2(35.0, 12.0)
	camera_pivot.call("_unhandled_input", right_drag)
	if camera_pivot.rotation.is_equal_approx(initial_camera_rotation):
		_fail("A right-side touch drag did not rotate the camera.")
		return

	# Turning the character body must not drag the camera's world-space yaw.
	var camera_world_yaw: float = camera_pivot.global_rotation.y
	player.rotation.y += deg_to_rad(90.0)
	camera_pivot.call("_process", 0.016)
	if not is_equal_approx(wrapf(camera_pivot.global_rotation.y - camera_world_yaw, -PI, PI), 0.0):
		_fail("Rotating the player body changed the camera world yaw.")
		return

	print("PASS: joystick touch drives movement, release clears input, left touch is isolated, and right drag controls camera.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
