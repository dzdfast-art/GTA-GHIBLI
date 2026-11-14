extends SceneTree

const NEEDS_SCRIPT = preload("res://scripts/systems/player_needs.gd")

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var needs := Node.new()
	needs.set_script(NEEDS_SCRIPT)
	needs.set("persistence_enabled", false)
	root.add_child(needs)
	needs.set("hunger", 35.0)
	needs.set("thirst", 20.0)
	needs.set("energy", 30.0)
	needs.call("consume_food", 40.0, 15.0, 10.0)
	if not is_equal_approx(float(needs.get("hunger")), 75.0):
		_fail("Food did not restore hunger.")
		return
	if not is_equal_approx(float(needs.get("thirst")), 35.0):
		_fail("Food hydration did not restore thirst.")
		return
	if not is_equal_approx(float(needs.get("energy")), 40.0):
		_fail("Food energy did not restore energy.")
		return
	needs.call("drink", 50.0)
	if not is_equal_approx(float(needs.get("thirst")), 85.0):
		_fail("Drinking did not restore thirst.")
		return
	needs.call("rest", 10.0)
	if float(needs.get("energy")) <= 40.0:
		_fail("Rest did not restore energy.")
		return
	needs.set("hunger", 5.0)
	if not is_equal_approx(float(needs.call("get_movement_multiplier")), 0.72):
		_fail("Critical hunger did not apply the movement penalty.")
		return
	print("PASS: Food, drink, rest, movement penalty and needs state.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
