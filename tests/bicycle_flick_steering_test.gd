extends SceneTree

const WORLD = preload("res://tests/helpers/bicycle_test_world.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var w: Dictionary = await WORLD.build(self)
	var bicycle: CharacterBody3D = w["bicycle"]
	var controls: CanvasLayer = w["controls"]
	bicycle.call("interact")
	if bicycle.get("driver") != w["player"]:
		WORLD.fail(self, "could not mount the bicycle.")
		return
	controls.call("set_bike_steering_mode", "flick")
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.pressed = true
	touch.position = Vector2(100.0, 300.0)
	controls.call("_input", touch)
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = Vector2(160.0, 300.0)
	drag.relative = Vector2(40.0, 0.0)
	controls.call("_input", drag)
	var a := Input.get_action_strength("bike_steer_right")
	drag.relative = Vector2(1.0, 0.0)
	controls.call("_input", drag)
	var b := Input.get_action_strength("bike_steer_right")
	if a < 0.3 or a > 0.7 or not is_equal_approx(a, b):
		WORLD.fail(self, "60px flick strength wrong or depends on relative.x (%f vs %f)." % [a, b])
		return
	if Input.get_action_strength("bike_steer_left") > 0.0:
		WORLD.fail(self, "left action pressed while dragging right.")
		return
	drag.position = Vector2(40.0, 300.0)
	controls.call("_input", drag)
	if Input.get_action_strength("bike_steer_left") < 0.3 or Input.get_action_strength("bike_steer_right") > 0.0:
		WORLD.fail(self, "left offset should press only left.")
		return
	drag.position = Vector2(100.0, 300.0)
	controls.call("_input", drag)
	if Input.is_action_pressed("bike_steer_left") or Input.is_action_pressed("bike_steer_right"):
		WORLD.fail(self, "returning to start should release steering.")
		return
	drag.position = Vector2(105.0, 300.0)
	controls.call("_input", drag)
	if Input.is_action_pressed("bike_steer_right"):
		WORLD.fail(self, "5px offset is inside dead zone.")
		return
	drag.position = Vector2(260.0, 300.0)
	controls.call("_input", drag)
	if Input.get_action_strength("bike_steer_right") < 0.95:
		WORLD.fail(self, "160px offset should give full strength.")
		return
	touch.pressed = false
	controls.call("_input", touch)
	if Input.is_action_pressed("bike_steer_left") or Input.is_action_pressed("bike_steer_right"):
		WORLD.fail(self, "lifting finger should release steering.")
		return
	print("PASS: flick steering left, right, return, dead zone, full, lift.")
	quit(0)
