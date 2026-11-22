extends SceneTree

## Browser-oriented input regression: WASD movement and right-mouse camera look.
## This runs headlessly in CI; it does not require or emulate a physical phone.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const WEB_CONTROLS_SCRIPT = preload("res://scripts/ui/mobile_controls.gd")


func _initialize() -> void:
	call_deferred("_run_web_input_test")


func _run_web_input_test() -> void:
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

	var controls := WEB_CONTROLS_SCRIPT.new() as CanvasLayer
	world.add_child(controls)
	await process_frame
	await physics_frame

	var expected_keys := {
		&"ui_up": KEY_W,
		&"ui_down": KEY_S,
		&"ui_left": KEY_A,
		&"ui_right": KEY_D,
	}
	for action in expected_keys:
		var found := false
		for event in InputMap.action_get_events(action):
			if event is InputEventKey and event.physical_keycode == expected_keys[action]:
				found = true
				break
		if not found:
			_fail("The Web keyboard profile is missing " + OS.get_keycode_string(expected_keys[action]) + " for " + String(action) + ".")
			return

	var camera := player.get_node("CameraPivot") as Node3D
	var yaw_before := camera.global_rotation.y
	var mouse_down := InputEventMouseButton.new()
	mouse_down.button_index = MOUSE_BUTTON_RIGHT
	mouse_down.pressed = true
	camera.call("_unhandled_input", mouse_down)
	var mouse_motion := InputEventMouseMotion.new()
	mouse_motion.screen_relative = Vector2(48.0, 0.0)
	camera.call("_unhandled_input", mouse_motion)
	var mouse_up := InputEventMouseButton.new()
	mouse_up.button_index = MOUSE_BUTTON_RIGHT
	mouse_up.pressed = false
	camera.call("_unhandled_input", mouse_up)
	if is_equal_approx(wrapf(camera.global_rotation.y - yaw_before, -PI, PI), 0.0):
		_fail("Holding right mouse and moving the pointer did not rotate the Web camera.")
		return

	var start_position := player.global_position
	var key_down := InputEventKey.new()
	key_down.physical_keycode = KEY_W
	key_down.pressed = true
	Input.parse_input_event(key_down)
	for _frame in range(24):
		await physics_frame
	var key_up := InputEventKey.new()
	key_up.physical_keycode = KEY_W
	key_up.pressed = false
	Input.parse_input_event(key_up)
	if player.global_position.distance_to(start_position) < 0.15:
		_fail("W did not move the player through the configured ui_up action.")
		return

	Input.action_release(&"ui_up")
	print("PASS: Web WASD key bindings, actual W movement, and right-mouse camera orbit.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
