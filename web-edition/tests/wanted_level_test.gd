extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var script = load("res://scripts/world/wanted_level.gd")
	if script == null:
		_fail("Wanted level implementation did not load.")
		return
	var model = script.new()
	if not _expect(model.get_level() == 0, "Wanted level must start at zero."):
		return
	if not _expect(model.add_crime(2) == 2, "Adding a severity-2 crime must set wanted level to 2."):
		return
	if not _expect(model.add_crime(99) == 5, "Wanted level must clamp to its maximum of 5."):
		return
	if not _expect(model.reduce_by_arrest() == 3, "Arrest must reduce wanted level by two."):
		return
	if not _expect(model.tick(29.0, true) == 3, "Wanted level must not decay before 30 hidden seconds."):
		return
	if not _expect(model.tick(31.0, true) == 1, "Two complete hidden cooldown intervals must reduce level 3 to 1."):
		return
	if not _expect(model.tick(60.0, false) == 1, "Wanted level must not decay while the player is visible."):
		return
	if not _expect(model.configure(3), "A positive wanted-level cap must be accepted."):
		return
	if not _expect(model.add_crime(1) == 2, "A new crime must increase the current level and reset cooldown."):
		return
	print("PASS: Wanted level escalation, arrest reduction and hidden cooldown.")
	quit(0)

func _expect(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
