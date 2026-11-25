extends SceneTree

const VITALS_SCRIPT = preload("res://scripts/systems/player_vitals.gd")


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var vitals := Node.new()
	vitals.set_script(VITALS_SCRIPT)
	root.add_child(vitals)
	await process_frame

	if not is_equal_approx(float(vitals.call("get_health")), 100.0):
		_fail("Player health did not initialize to 100.")
		return
	if not bool(vitals.call("take_damage", 25.0)):
		_fail("Player vitals rejected valid damage.")
		return
	if not is_equal_approx(float(vitals.call("get_health")), 75.0):
		_fail("Damage did not reduce player health.")
		return
	if not bool(vitals.call("heal", 10.0)):
		_fail("Player vitals rejected valid healing.")
		return
	if not is_equal_approx(float(vitals.call("get_health")), 85.0):
		_fail("Healing did not restore player health.")
		return
	if not bool(vitals.call("take_damage", 500.0)) or not bool(vitals.call("is_dead")):
		_fail("Lethal damage did not trigger the dead state.")
		return
	if bool(vitals.call("heal", 20.0)):
		_fail("Healing unexpectedly revived a dead player.")
		return
	vitals.call("reset")
	if not is_equal_approx(float(vitals.call("get_health")), 100.0):
		_fail("Reset did not restore the player to full health.")
		return

	print("PASS: player health initialization, damage, healing, death and reset.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
