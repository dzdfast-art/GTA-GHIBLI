extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/mission_rewards.gd").new()
	assert(m.settle("m1",500,10).ok)
	assert(not m.settle("m1",500,10).ok)
	assert(m.get_reward("m1").cash==500 and m.is_settled("m1"))
	print("PASS: Mission Reward Settlement.")
	quit(0)
