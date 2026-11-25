extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/touch_control_zones.gd").new()
	assert(m.register_zone("left",Rect2(Vector2.ZERO,Vector2(100,100)),"move"))
	assert(m.action_at(Vector2(50,50))=="move")
	assert(m.action_at(Vector2(150,50))=="")
	assert(m.remove_zone("left") and m.action_at(Vector2(50,50))=="")
	print("PASS: Mobile Touch Control Zones.")
	quit(0)
