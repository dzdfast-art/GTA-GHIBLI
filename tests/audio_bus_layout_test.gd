extends SceneTree

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var required_buses := ["Master", "Music", "SFX", "Dialogue"]
	for bus_name in required_buses:
		var bus_index := AudioServer.get_bus_index(bus_name)
		if bus_index < 0:
			_fail("Required audio bus is missing: " + bus_name)
			return
		if bus_name != "Master" and AudioServer.get_bus_send(bus_index) != "Master":
			_fail("Audio bus must route to Master: " + bus_name)
			return

	var ambience := AudioStreamPlayer.new()
	ambience.bus = "SFX"
	root.add_child(ambience)
	if AudioServer.get_bus_index(ambience.bus) < 0:
		_fail("World ambience cannot resolve the SFX bus.")
		return

	print("PASS: Master, Music, SFX and Dialogue buses exist; secondary buses route to Master.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
