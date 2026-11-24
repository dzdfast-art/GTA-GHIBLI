extends SceneTree

const SLOT_ID: String = "process_restart_probe"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var user_args: PackedStringArray = OS.get_cmdline_user_args()
	if user_args.has("--write"):
		_run_writer_process()
		return
	if user_args.has("--read"):
		_run_reader_process()
		return

	var executable: String = OS.get_executable_path()
	var project_path: String = ProjectSettings.globalize_path("res://")
	var writer_output: Array = []
	var writer_arguments := PackedStringArray([
		"--headless",
		"--path",
		project_path,
		"--script",
		"res://tests/save_slot_restart_test.gd",
		"--",
		"--write"
	])
	var writer_status: int = OS.execute(executable, writer_arguments, writer_output, true)
	if writer_status != 0:
		_cleanup_probe()
		push_error("Save writer process failed: %s" % str(writer_output))
		quit(1)
		return

	var reader_output: Array = []
	var reader_arguments := PackedStringArray([
		"--headless",
		"--path",
		project_path,
		"--script",
		"res://tests/save_slot_restart_test.gd",
		"--",
		"--read"
	])
	var reader_status: int = OS.execute(executable, reader_arguments, reader_output, true)
	if reader_status != 0:
		_cleanup_probe()
		push_error("Save reader process failed: %s" % str(reader_output))
		quit(1)
		return

	print("PASS: save data survived a separate Godot process restart.")
	quit(0)


func _run_writer_process() -> void:
	var manager: RefCounted = load("res://scripts/world/save_slot_manager.gd").new()
	manager.call("delete_slot", SLOT_ID)
	var payload: Dictionary = {
		"money": 975,
		"player": {"health": 83.5, "stamina": 61.0, "position": [-24.0, 0.0, 18.0]},
		"missions": {"mission_001": 2, "mission_002": 0, "mission_003": 0, "mission_004": 0},
		"inventory": {"water": 2, "medkit": 1},
		"vehicle": {"id": "harbor_sedan", "fuel": 63.2},
		"world": {"minute_of_day": 615, "weather": "rain"},
		"activities": {"lighthouse_view": true}
	}
	if not bool(manager.call("save_slot", SLOT_ID, payload, 1234567890)):
		push_error("The writer process could not persist its save payload.")
		quit(1)
		return
	print("PASS: writer process persisted nested gameplay state.")
	quit(0)


func _run_reader_process() -> void:
	var manager: RefCounted = load("res://scripts/world/save_slot_manager.gd").new()
	var record: Dictionary = manager.call("load_slot", SLOT_ID)
	var payload: Dictionary = record.get("payload", {})
	var player: Dictionary = payload.get("player", {})
	var missions: Dictionary = payload.get("missions", {})
	var inventory: Dictionary = payload.get("inventory", {})
	var vehicle: Dictionary = payload.get("vehicle", {})
	var world: Dictionary = payload.get("world", {})
	var activities: Dictionary = payload.get("activities", {})
	if record.is_empty() or int(payload.get("money", -1)) != 975:
		push_error("The reader process could not restore the saved wallet.")
		quit(1)
		return
	if absf(float(player.get("health", -1.0)) - 83.5) > 0.001 or missions.get("mission_001") != 2:
		push_error("The reader process did not restore player or mission state.")
		quit(1)
		return
	if int(inventory.get("water", -1)) != 2 or str(vehicle.get("id", "")) != "harbor_sedan":
		push_error("The reader process did not restore inventory or vehicle state.")
		quit(1)
		return
	if int(world.get("minute_of_day", -1)) != 615 or str(world.get("weather", "")) != "rain":
		push_error("The reader process did not restore world time and weather.")
		quit(1)
		return
	if not bool(activities.get("lighthouse_view", false)):
		push_error("The reader process did not restore activity completion state.")
		quit(1)
		return
	if not bool(manager.call("delete_slot", SLOT_ID)):
		push_error("The reader process could not clean up its restart probe.")
		quit(1)
		return
	print("PASS: independent reader process restored player, missions, wallet, inventory, vehicle, world and activity data.")
	quit(0)


func _cleanup_probe() -> void:
	var manager: RefCounted = load("res://scripts/world/save_slot_manager.gd").new()
	manager.call("delete_slot", SLOT_ID)
	manager.free()
