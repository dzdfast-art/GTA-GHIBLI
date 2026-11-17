extends SceneTree

const HEALTH_SCRIPT = preload("res://scripts/systems/player_health.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var health: Node = HEALTH_SCRIPT.new()
	root.add_child(health)
	await process_frame
	if not is_equal_approx(float(health.get("current_health")), 100.0):
		push_error("Player health did not initialize to 100.")
		quit(1)
		return
	if not bool(health.call("apply_damage", 35.0, &"test")):
		push_error("Player health rejected valid damage.")
		quit(1)
		return
	if not is_equal_approx(float(health.get("current_health")), 65.0):
		push_error("Player health damage amount was incorrect.")
		quit(1)
		return
	if not bool(health.call("heal", 20.0)):
		push_error("Player health rejected valid healing.")
		quit(1)
		return
	if not is_equal_approx(float(health.get("current_health")), 85.0):
		push_error("Player health healing amount was incorrect.")
		quit(1)
		return
	health.call("apply_damage", 200.0)
	if bool(health.call("is_alive")):
		push_error("Player should be dead at zero health.")
		quit(1)
		return
	health.call("restore_full")
	if not bool(health.call("is_alive")) or not is_equal_approx(float(health.get("current_health")), 100.0):
		push_error("Player health did not restore correctly.")
		quit(1)
		return
	print("PASS: player health damage, healing, death and restore.")
	quit(0)
