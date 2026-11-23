extends SceneTree

const WORLD = preload("res://tests/helpers/bicycle_test_world.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var w: Dictionary = await WORLD.build(self)
	var bicycle: CharacterBody3D = w["bicycle"]
	bicycle.call("interact")
	if bicycle.get("driver") != w["player"]:
		WORLD.fail(self, "could not mount the bicycle.")
		return
	Input.action_press("bike_pedal")
	for _frame in range(30):
		await physics_frame
	var before: Vector3 = -bicycle.global_basis.z
	Input.action_press("bike_steer_right")
	for _frame in range(20):
		await physics_frame
	Input.action_release("bike_steer_right")
	var after_right: Vector3 = -bicycle.global_basis.z
	if before.cross(after_right).y <= 0.0:
		WORLD.fail(self, "steering right did not turn clockwise/right.")
		return
	Input.action_press("bike_steer_left")
	for _frame in range(40):
		await physics_frame
	Input.action_release("bike_steer_left")
	var after_left: Vector3 = -bicycle.global_basis.z
	if after_right.cross(after_left).y >= 0.0:
		WORLD.fail(self, "steering left did not turn counter-clockwise/left.")
		return
	Input.action_release("bike_pedal")
	print("PASS: right and left steering directions.")
	quit(0)
