extends SceneTree

const AMBIENCE_SCRIPT = preload("res://scripts/audio/nature_ambience.gd")
const EXPECTED_THEMES := ["dawn", "forest_day", "night", "coast", "rain", "storm"]

var _ambience_node: Node

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var ambience := Node.new()
	_ambience_node = ambience
	ambience.set_script(AMBIENCE_SCRIPT)
	ambience.set_meta("asset_validation_only", true)
	root.add_child(ambience)
	await process_frame
	await process_frame
	if str(ambience.get("_field_recording_theme")) != "dawn":
		_fail("The dawn ambience track was not selected at the opening game hour.")
		return
	var opening_paths: PackedStringArray = ambience.call("get_field_recording_paths", "dawn")
	if opening_paths.is_empty():
		_fail("The dawn ambience theme has no source recordings.")
		return
	var opening_asset := load(opening_paths[0]) as AudioStreamWAV
	if opening_asset == null or opening_asset.mix_rate != 22050 or not opening_asset.stereo:
		_fail("The dawn PCM audio asset is missing or has an invalid format.")
		return
	opening_asset = null
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
			var valid_duration := asset.get_length() >= 20.0 and asset.get_length() <= 23.0
			asset = null
			if not valid_duration:
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
	_release_ambience()
	await process_frame
	print("PASS: Six original stereo ambience variations per theme load and switch by time, biome and weather.")
	quit(0)


func _release_ambience() -> void:
	if not is_instance_valid(_ambience_node):
		return
	var transition: Tween = _ambience_node.get("_transition_tween") as Tween
	if transition != null and transition.is_running():
		transition.kill()
	_ambience_node.set("_transition_tween", null)
	_ambience_node.set("_playback", null)
	for property_name in ["_field_recording_player", "_player"]:
		var audio_player: AudioStreamPlayer = _ambience_node.get(property_name) as AudioStreamPlayer
		if audio_player != null:
			audio_player.stop()
			audio_player.stream = null
			audio_player.queue_free()
		_ambience_node.set(property_name, null)
	_ambience_node.free()
	_ambience_node = null


func _fail(message: String) -> void:
	_release_ambience()
	push_error("FAIL: " + message)
	quit(1)
