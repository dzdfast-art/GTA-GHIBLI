extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/camera_input_isolation.gd").new()
		m.set_move(Vector2(2,0))
		m.set_look(Vector2(0,1))
		assert(m.consume_move().length()<=1.001)
		assert(m.consume_look()==Vector2(0,1))
		assert(m.consume_move()==Vector2.ZERO)
		m.clear_all()
		assert(m.consume_look()==Vector2.ZERO)
	print("PASS: Camera and Movement Input Isolation.")
	quit(0)
