extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/safehouse_registry.gd").new()
		assert(m.register_house("flat",Vector3.ONE,500))
		assert(not m.purchase("flat",100).ok)
		assert(m.purchase("flat",600).wallet==100)
		assert(m.owns("flat") and not m.purchase("flat",1000).ok)
	print("PASS: Safehouse Ownership and Rest.")
	quit(0)
