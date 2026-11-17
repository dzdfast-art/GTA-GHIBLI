extends SceneTree

const WORLD = preload("res://tests/helpers/bicycle_test_world.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var w: Dictionary = await WORLD.build(self)
	var player: CharacterBody3D = w["player"]
	var bicycle: CharacterBody3D = w["bicycle"]
	var controls: CanvasLayer = w["controls"]
	bicycle.call("interact")
	if bicycle.get("driver") != player:
		WORLD.fail(self, "could not mount the bicycle.")
		return
	controls.call("_on_joystick_vector_changed", Vector2(1.0, 0.0))
	for _frame in range(10):
		await physics_frame
	var visuals := bicycle.get_node("BicycleVisuals") as Node3D
	if absf(visuals.rotation.z) < 0.01:
		WORLD.fail(self, "precondition: bicycle did not lean while steering.")
		return
	player.free()
	for _frame in range(3):
		await physics_frame
	if Input.is_action_pressed("bike_steer_right"):
		WORLD.fail(self, "steering stayed pressed after driver was freed.")
		return
	if (controls.get_node("HUD/ContextAction") as Button).text == "EXIT BIKE":
		WORLD.fail(self, "HUD stayed in bicycle mode after driver was freed.")
		return
	if absf(float(bicycle.get("_speed"))) > 0.0001 or absf(visuals.rotation.z) > 0.001:
		WORLD.fail(self, "speed or visual lean was not reset.")
		return
	print("PASS: freed driver cleanup (physics path).")
	quit(0)
