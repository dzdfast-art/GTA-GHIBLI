extends SceneTree

const WORLD = preload("res://tests/helpers/bicycle_test_world.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var w: Dictionary = await WORLD.build(self)
	var bicycle: CharacterBody3D = w["bicycle"]
	for wheel_name in ["FrontWheel", "RearWheel"]:
		var tire := bicycle.get_node("BicycleVisuals/%s/Tire" % wheel_name) as MeshInstance3D
		var box: AABB = tire.global_transform * tire.get_aabb()
		if box.size.y < 0.8 or box.size.x > 0.3:
			WORLD.fail(self, "%s tire AABB is %s (expected tall and thin)." % [wheel_name, box.size])
			return
	print("PASS: both wheels stand upright.")
	quit(0)
