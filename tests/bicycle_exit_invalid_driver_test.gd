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
	player.free()
	bicycle.call("_exit_bicycle")
	if (controls.get_node("HUD/ContextAction") as Button).text == "EXIT BIKE":
		WORLD.fail(self, "early exit branch left HUD in bicycle mode.")
		return
	if absf(float(bicycle.get("_speed"))) > 0.0001:
		WORLD.fail(self, "early exit branch did not reset speed.")
		return
	if absf((bicycle.get_node("BicycleVisuals") as Node3D).rotation.z) > 0.001:
		WORLD.fail(self, "early exit branch did not reset lean.")
		return
	print("PASS: _exit_bicycle early branch cleanup.")
	quit(0)
