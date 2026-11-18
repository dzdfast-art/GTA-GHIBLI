extends SceneTree

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var file := FileAccess.open("res://data/characters/world_dialogue_ar.json", FileAccess.READ)
	if file == null:
		_fail("Arabic dialogue data file is missing.")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		_fail("Arabic dialogue JSON is invalid.")
		return
	var total := 0
	for character_id in parsed.get("characters", {}):
		for line in parsed.characters[character_id].get("lines", []):
			total += 1
			if not line.has("emotion_id") or not line.has("performance_direction_ar") or not line.has("performance_recording_status"):
				_fail("Dialogue line lacks emotion performance metadata: " + str(line.get("line_id", "unknown")))
				return
	if total < 20:
		_fail("Expected the existing character dialogue library to contain at least 20 lines.")
		return
	print("PASS: %d Arabic dialogue lines have explicit acting and emotion direction." % total)
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
