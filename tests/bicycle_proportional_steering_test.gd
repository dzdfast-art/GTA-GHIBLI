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
	controls.call("_on_joystick_vector_changed", Vector2(0.1, 0.0))
	if Input.get_action_strength("bike_steer_right") > 0.0:
		WORLD.fail(self, "tilt inside dead zone should not steer.")
		return
	controls.call("_on_joystick_vector_changed", Vector2(0.3, 0.0))
	var partial := Input.get_action_strength("bike_steer_right")
	if partial < 0.1 or partial > 0.5:
		WORLD.fail(self, "tilt 0.3 gave strength %f (expected 0.1-0.5)." % partial)
		return
	controls.call("_on_joystick_vector_changed", Vector2(1.0, 0.0))
	if Input.get_action_strength("bike_steer_right") < 0.95:
		WORLD.fail(self, "full tilt did not give full strength.")
		return
	controls.call("_on_joystick_vector_changed", Vector2(-0.6, 0.0))
	if Input.get_action_strength("bike_steer_left") <= 0.0 or Input.get_action_strength("bike_steer_right") > 0.0:
		WORLD.fail(self, "left tilt should press only the left action.")
		return
	controls.call("_on_joystick_vector_changed", Vector2.ZERO)
	if Input.is_action_pressed("bike_steer_left") or Input.is_action_pressed("bike_steer_right"):
		WORLD.fail(self, "centered stick should release both actions.")
		return
	controls.call("_on_joystick_vector_changed", Vector2(1.0, 0.0))
	bicycle.call("interact")
	for action in ["bike_pedal", "bike_brake", "bike_steer_left", "bike_steer_right"]:
		if Input.is_action_pressed(action):
			WORLD.fail(self, "action '%s' stayed pressed after dismount." % action)
			return
	print("PASS: proportional steering and release on dismount.")
	quit(0)
