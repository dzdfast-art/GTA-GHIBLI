extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/economy_ledger.gd").new()
	assert(m.transact(100,"mission"))
	assert(m.transact(-30,"shop"))
	assert(m.get_balance()==70 and m.history().size()==2)
	assert(not m.transact(-100,"overspend"))
	print("PASS: Player Economy Ledger.")
	quit(0)
