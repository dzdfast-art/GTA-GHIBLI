extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/web_acceptance_gate.gd").new()
	assert(not m.can_release() and m.missing().size()==6)
	for item in ["world","player","vehicle","gps","hud","save"]: assert(m.record(item,true))
	assert(m.can_release())
	assert(not m.record("unknown",true))
	print("PASS: Web Edition Acceptance Gate.")
	quit(0)
