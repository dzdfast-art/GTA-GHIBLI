extends SceneTree

const AMBIENCE_SCRIPT = preload("res://scripts/audio/nature_ambience.gd")

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
	var stream := player.stream as AudioStreamWAV
	if stream.mix_rate != 22050 or stream.stereo == false or stream.get_length() < 20.0:
		_fail("The loaded ambience WAV did not match the expected stereo format and duration.")
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
	print("PASS: Original stereo ambience WAVs load and switch by time, biome and weather.")

	# Stop playback and release the test-owned players before the SceneTree exits.
	var procedural_player := ambience.get_node_or_null("ProceduralNatureAudio") as AudioStreamPlayer
	var recording_player := ambience.get_node_or_null("OriginalFieldAmbience") as AudioStreamPlayer
	if procedural_player != null:
		procedural_player.stop()
	if recording_player != null:
		recording_player.stop()
	stream = null
	player = null
	ambience.queue_free()
	await process_frame
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
