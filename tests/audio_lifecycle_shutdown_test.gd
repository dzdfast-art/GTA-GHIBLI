extends SceneTree

func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var ambience_script := load("res://scripts/audio/nature_ambience.gd") as Script
	if ambience_script == null:
		_fail("Nature ambience script could not be loaded.")
		return
	var ambience := ambience_script.new() as Node
	root.add_child(ambience)
	await process_frame

	var procedural_player := ambience.get_node_or_null("ProceduralNatureAudio") as AudioStreamPlayer
	var field_player := ambience.get_node_or_null("OriginalFieldAmbience") as AudioStreamPlayer
	if procedural_player == null or field_player == null:
		_fail("Both ambience players must be created by the live ambience system.")
		return
	if not procedural_player.playing:
		_fail("Procedural nature ambience did not start.")
		return
	if not field_player.playing:
		_fail("Original field-recording ambience did not start.")
		return

	ambience.call("_stop_audio_players")
	if procedural_player.playing or procedural_player.stream != null:
		_fail("Procedural ambience did not stop and release its stream.")
		return
	if field_player.playing or field_player.stream != null:
		_fail("Field-recording ambience did not stop and release its stream.")
		return
	ambience.free()
	ambience = null
	procedural_player = null
	field_player = null
	ambience_script = null

	var voice_script := load("res://scripts/audio/wildlife_voice.gd") as Script
	if voice_script == null:
		_fail("Wildlife voice script could not be loaded.")
		return
	var wildlife_voice := voice_script.new() as AudioStreamPlayer3D
	wildlife_voice.species_id = "rabbit"
	root.add_child(wildlife_voice)
	await process_frame
	wildlife_voice.stream = wildlife_voice.call("_make_call") as AudioStream
	wildlife_voice.play()
	if not wildlife_voice.playing:
		_fail("The wildlife voice test could not start playback.")
		return
	wildlife_voice.call("_stop_voice")
	if wildlife_voice.playing or wildlife_voice.stream != null:
		_fail("Wildlife voice did not stop and release its stream.")
		return
	wildlife_voice.free()
	wildlife_voice = null
	voice_script = null
	await process_frame
	await process_frame
	print("PASS: procedural ambience, field recordings and wildlife calls stop and release audio streams during scene teardown.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
