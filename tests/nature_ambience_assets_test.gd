extends SceneTree

const AMBIENCE_SCRIPT = preload("res://scripts/audio/nature_ambience.gd")
const EXPECTED_THEMES := ["dawn", "forest_day", "night", "coast", "rain", "storm"]

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var ambience := Node.new()
	ambience.set_script(AMBIENCE_SCRIPT)
	root.add_child(ambience)
	await process_frame
	await process_frame
	if str(ambience.get("_field_recording_theme")) != "dawn":
		_fail("The dawn ambience track was not selected at the opening game hour.")
		return
	var player := ambience.get("_field_recording_player") as AudioStreamPlayer
	if player == null or not (player.stream is AudioStreamWAV):
		_fail("The dawn PCM audio asset did not load into the audio player.")
		return
	for theme in EXPECTED_THEMES:
		var paths: PackedStringArray = ambience.call("get_field_recording_paths", theme)
		if paths.size() != 6:
			_fail("Expected six sequential ambience variations for theme: " + theme)
			return
		for path in paths:
			if not ResourceLoader.exists(path):
				_fail("An ambience variation is missing: " + path)
				return
			var asset := load(path) as AudioStreamWAV
			if asset == null or asset.mix_rate != 22050 or not asset.stereo:
				_fail("An ambience variation is not stereo 22050 Hz PCM WAV: " + path)
				return
			if asset.get_length() < 20.0 or asset.get_length() > 23.0:
				_fail("An ambience variation has an unexpected duration: " + path)
				return
	if str(ambience.get("_field_recording_theme")) != "dawn":
		_fail("The opening ambience theme changed unexpectedly during validation.")
		return
	ambience.call("set_biome", "coast")
	if str(ambience.get("_field_recording_theme")) != "coast":
		_fail("Coastal ambience was not selected for the coastal biome.")
		return
	ambience.call("set_weather", "rain")
	if str(ambience.get("_field_recording_theme")) != "rain":
		_fail("Rain ambience did not override the biome ambience.")
		return
	ambience.call("set_weather", "storm")
	if str(ambience.get("_field_recording_theme")) != "storm":
		_fail("Storm ambience was not selected.")
		return
	ambience.call("set_weather", "clear")
	if str(ambience.get("_field_recording_theme")) != "coast":
		_fail("Clearing the weather did not restore coastal ambience.")
		return
	print("PASS: Six original stereo ambience variations per theme load and switch by time, biome and weather.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
