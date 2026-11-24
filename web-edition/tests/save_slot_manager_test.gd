extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manager: RefCounted = load("res://scripts/world/save_slot_manager.gd").new()
	manager.call("delete_slot", "one")
	manager.call("delete_slot", "legacy")

	var original_payload: Dictionary = {
		"cash": 50,
		"player": {"health": 92.5, "position": [12.0, 0.0, -8.0]}
	}
	if not bool(manager.call("save_slot", "one", original_payload, 100)):
		_fail("A valid save slot could not be written.")
		return
	original_payload["player"]["health"] = 1.0
	var first_record: Dictionary = manager.call("load_slot", "one")
	var first_payload: Dictionary = first_record.get("payload", {})
	var first_player: Dictionary = first_payload.get("player", {})
	if int(first_payload.get("cash", -1)) != 50 or absf(float(first_player.get("health", -1.0)) - 92.5) > 0.001:
		_fail("Save data did not round-trip as an isolated deep copy.")
		return
	if int(first_record.get("version", -1)) != 1 or int(first_record.get("timestamp", -1)) != 100:
		_fail("Save metadata did not retain its schema version and timestamp.")
		return

	if not bool(manager.call("save_slot", "one", {"cash": 75}, 200)):
		_fail("A second save could not replace the existing slot.")
		return
	var corrupt_file := FileAccess.open("user://gta_ghibli_web_saves/one.json", FileAccess.WRITE)
	if corrupt_file == null:
		_fail("The test could not open the current save to simulate corruption.")
		return
	corrupt_file.store_string("{broken")
	corrupt_file.flush()
	corrupt_file.close()
	var recovered_record: Dictionary = manager.call("load_slot", "one")
	var recovered_payload: Dictionary = recovered_record.get("payload", {})
	if int(recovered_payload.get("cash", -1)) != 50:
		_fail("The previous valid save was not recovered after current-slot corruption.")
		return
	if not manager.call("list_slots").has("one"):
		_fail("The valid recovered slot was missing from the slot list.")
		return

	if bool(manager.call("save_slot", "../escape", {}, 300)) or not manager.call("load_slot", "../escape").is_empty():
		_fail("Path traversal was not rejected as an invalid slot ID.")
		return
	if bool(manager.call("save_slot", "negative_time", {}, -1)):
		_fail("A negative save timestamp was accepted.")
		return
	if not bool(manager.call("delete_slot", "one")) or not manager.call("load_slot", "one").is_empty():
		_fail("Deleting a save slot did not remove its primary and recovery files.")
		return

	var invalid_payload_json: String = "{broken"
	var invalid_payload_envelope: Dictionary = {
		"version": 1,
		"slot_id": "invalid_payload",
		"timestamp": 400,
		"payload_json": invalid_payload_json,
		"checksum": manager.call("_calculate_checksum", invalid_payload_json)
	}
	var invalid_payload_file := FileAccess.open(
		"user://gta_ghibli_web_saves/invalid_payload.json", FileAccess.WRITE
	)
	if invalid_payload_file == null:
		_fail("The test could not create an invalid-payload save envelope.")
		return
	invalid_payload_file.store_string(JSON.stringify(invalid_payload_envelope))
	invalid_payload_file.flush()
	invalid_payload_file.close()
	if not manager.call("load_slot", "invalid_payload").is_empty():
		_fail("A payload with invalid JSON was accepted despite a matching checksum.")
		return
	manager.call("delete_slot", "invalid_payload")

	if not bool(manager.call("save_slot", "empty_payload", {}, 401)):
		_fail("An empty but valid dictionary payload could not be saved.")
		return
	var empty_record: Dictionary = manager.call("load_slot", "empty_payload")
	if empty_record.is_empty() or not empty_record.get("payload", {}).is_empty():
		_fail("An empty dictionary payload did not round-trip.")
		return
	manager.call("delete_slot", "empty_payload")
	print("PASS: invalid JSON payloads are rejected without treating valid empty dictionaries as corrupt.")

	var legacy_payload_json: String = JSON.stringify({"cash": 12})
	var legacy_envelope: Dictionary = {
		"version": 0,
		"slot_id": "legacy",
		"timestamp": 300,
		"payload_json": legacy_payload_json,
		"checksum": manager.call("_calculate_checksum", legacy_payload_json)
	}
	var legacy_file := FileAccess.open("user://gta_ghibli_web_saves/legacy.json", FileAccess.WRITE)
	if legacy_file == null:
		_fail("The test could not create a version-zero save for migration.")
		return
	legacy_file.store_string(JSON.stringify(legacy_envelope))
	legacy_file.flush()
	legacy_file.close()
	var migrated_record: Dictionary = manager.call("load_slot", "legacy")
	var migrated_payload: Dictionary = migrated_record.get("payload", {})
	if int(migrated_payload.get("cash", -1)) != 12 or int(migrated_payload.get("schema_version", -1)) != 1:
		_fail("The version-zero save was not migrated to schema version one.")
		return
	manager.call("delete_slot", "legacy")

	print("PASS: durable save slots, SHA-256 integrity, atomic replacement and corruption recovery.")
	print("PASS: slot IDs reject path traversal; version-zero payloads migrate to version one.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
