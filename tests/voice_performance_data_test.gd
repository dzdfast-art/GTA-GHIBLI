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
	var mira_file := FileAccess.open("res://data/dialogue/mira_intro_ar.json", FileAccess.READ)
	if mira_file == null:
		_fail("Mira greeting voice record is missing.")
		return
	var mira_data = JSON.parse_string(mira_file.get_as_text())
	var greeting: Dictionary = mira_data.get("greeting", {}) if mira_data is Dictionary else {}
	if not str(greeting.get("audio_url", "")).contains("id=938b382f2c51457d852345ff8d830d47.mp3"):
		_fail("The refreshed Mira expressive voice URL is missing.")
		return
	if str(greeting.get("performance_recording_status", "")) != "new_tts_take_generated_not_yet_auditioned_on_device":
		_fail("Mira voice status must remain pending owner/device audition.")
	print("PASS: %d Arabic dialogue lines have acting metadata and Mira's refreshed voice sample is registered." % total)
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
