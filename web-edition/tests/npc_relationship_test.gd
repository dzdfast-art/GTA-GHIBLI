extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/npc_relationship.gd").new()
	assert(m.adjust("npc_a",80)==80)
	assert(m.get_tier("npc_a")=="friend")
	assert(m.adjust("npc_a",100)==100)
	assert(m.adjust("npc_a",-250)==-100)
	assert(m.get_tier("npc_a")=="hostile")
	
	print("PASS: NPC Relationship System.")
	quit(0)
