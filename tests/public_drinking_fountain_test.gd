extends SceneTree

const FOUNTAIN_SCENE = preload("res://scenes/world/public_drinking_fountain.tscn")
const NEEDS_SCRIPT = preload("res://scripts/systems/player_needs.gd")


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var player := CharacterBody3D.new()
	player.name = "FountainTestPlayer"
	player.add_to_group("player")
	root.add_child(player)

	var needs := Node.new()
	needs.name = "PlayerNeeds"
	needs.set_script(NEEDS_SCRIPT)
	needs.set("persistence_enabled", false)
	needs.set("thirst", 35.0)
	player.add_child(needs)

	var fountain := FOUNTAIN_SCENE.instantiate()
	root.add_child(fountain)
	var visual := fountain.get_node_or_null("Visual") as MeshInstance3D
	if visual == null or visual.mesh == null or visual.mesh.get_surface_count() < 3:
		_fail("The imported fountain model or its three material surfaces are missing.")
		return

	fountain.set("_player_nearby", true)
	var emitted: Array = []
	fountain.water_drunk.connect(func(amount: float, new_thirst: float): emitted.append([amount, new_thirst]))

	if not bool(fountain.call("interact")):
		_fail("A nearby player could not drink from the fountain.")
		return
	if not is_equal_approx(float(needs.get("thirst")), 65.0):
		_fail("The fountain did not restore exactly 30 thirst points.")
		return
	if emitted.size() != 1 or not is_equal_approx(float(emitted[0][0]), 30.0):
		_fail("The water_drunk signal did not report the actual restored amount.")
		return

	if bool(fountain.call("interact")):
		_fail("The fountain ignored its repeat-use cooldown.")
		return
	if not is_equal_approx(float(needs.get("thirst")), 65.0):
		_fail("A cooldown-blocked interaction changed thirst.")
		return

	fountain.set("_cooldown_remaining", 0.0)
	needs.set("thirst", 100.0)
	if bool(fountain.call("interact")):
		_fail("The fountain accepted a drink when thirst was already full.")
		return
	if not is_equal_approx(float(needs.get("thirst")), 100.0):
		_fail("A full thirst value changed after fountain interaction.")
		return

	fountain.set("_player_nearby", false)
	fountain.set("_cooldown_remaining", 0.0)
	needs.set("thirst", 40.0)
	if bool(fountain.call("interact")):
		_fail("The fountain allowed interaction outside its proximity range.")
		return
	if not is_equal_approx(float(needs.get("thirst")), 40.0):
		_fail("An out-of-range interaction changed the player needs.")
		return

	print("PASS: Imported fountain, proximity, hydration, cooldown and full-thirst guards.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
