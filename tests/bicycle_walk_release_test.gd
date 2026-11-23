extends SceneTree

const WORLD = preload("res://tests/helpers/bicycle_test_world.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var w: Dictionary = await WORLD.build(self)
	var bicycle: CharacterBody3D = w["bicycle"]
	var controls: CanvasLayer = w["controls"]
	controls.call("_on_joystick_vector_changed", Vector2(1.0, 0.0))
	if not Input.is_action_pressed("ui_right"):
		WORLD.fail(self, "precondition: on-foot stick did not press ui_right.")
		return
	bicycle.call("interact")
	if bicycle.get("driver") != w["player"]:
		WORLD.fail(self, "could not mount the bicycle.")
		return
	if Input.is_action_pressed("ui_right"):
		WORLD.fail(self, "ui_right stayed pressed while riding.")
		return
	print("PASS: on-foot actions are released when riding.")
	quit(0)
