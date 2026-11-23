extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var s=load("res://scripts/world/region_registry.gd"); var m=s.new()
		assert(m.register_region("harbor", Rect2(Vector2.ZERO, Vector2(100,100)), "Harbor"))
		assert(m.find_region(Vector2(10,10))=="harbor")
		assert(m.find_region(Vector2(200,200))=="")
		assert(not m.register_region("harbor", Rect2(Vector2.ZERO, Vector2.ONE), "Duplicate"))
	
	print("PASS: World Region Registry.")
	quit(0)
