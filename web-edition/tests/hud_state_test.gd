extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/hud_state.gd").new()
	m.update_health(120.0)
	assert(m.health==100.0)
	assert(m.add_money(50)==50 and m.add_money(-100)==0)
	m.set_wanted(9)
	assert(m.wanted==5 and m.set_clock(21,5))
	assert(not m.set_clock(24,0))
	print("PASS: Gameplay HUD State Model.")
	quit(0)
