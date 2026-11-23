extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/performance_budget.gd").new()
		assert(m.configure("npcs",2))
		assert(m.acquire("npcs",2) and not m.acquire("npcs"))
		assert(m.available("npcs")==0)
		assert(m.release("npcs")==1 and m.available("npcs")==1)
	print("PASS: Runtime Performance Budget.")
	quit(0)
