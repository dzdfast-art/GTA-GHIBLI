extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/npc_schedule.gd").new()
		assert(m.add_entry(480,600,"work","office"))
		assert(not m.add_entry(550,650,"shop","market"))
		assert(m.get_activity(500).activity=="work")
		assert(m.get_activity(700).activity=="idle")
	
	print("PASS: NPC Daily Schedules.")
	quit(0)
