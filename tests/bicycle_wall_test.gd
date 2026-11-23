extends SceneTree

const WORLD = preload("res://tests/helpers/bicycle_test_world.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var w: Dictionary = await WORLD.build(self, true)
	var bicycle: CharacterBody3D = w["bicycle"]
	bicycle.call("interact")
	if bicycle.get("driver") != w["player"]:
		WORLD.fail(self, "could not mount the bicycle.")
		return
	Input.action_press("bike_pedal")
	for _frame in range(240):
		await physics_frame
	Input.action_release("bike_pedal")
	if bicycle.global_position.z < 4.0:
		WORLD.fail(self, "test invalid: the bicycle never reached the wall (z=%f)." % bicycle.global_position.z)
		return
	if absf(float(bicycle.get("_speed"))) > 0.5:
		WORLD.fail(self, "bicycle kept speed %f while pressed against a wall." % float(bicycle.get("_speed")))
		return
	print("PASS: wall impact resets bicycle speed.")
	quit(0)
