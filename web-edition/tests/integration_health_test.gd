extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/integration_health.gd").new()
	assert(not m.is_healthy())
	assert(m.record_check("gps",true,"route planner available"))
	assert(m.record_check("vehicle",false,"controller not connected"))
	assert(not m.is_healthy() and m.get_report().passed==1)
	assert(m.record_check("vehicle",true) and m.is_healthy())
	print("PASS: Gameplay Integration Health Checks.")
	quit(0)
