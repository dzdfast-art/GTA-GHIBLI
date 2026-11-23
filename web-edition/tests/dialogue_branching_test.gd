extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/dialogue_branching.gd").new()
	assert(m.add_node("start","Hello",["help","leave"]))
	assert(m.choose("start",0)=="help")
	assert(m.choose("start",5)=="")
	assert(m.get_node("start").text=="Hello")
	print("PASS: Branching Dialogue State.")
	quit(0)
