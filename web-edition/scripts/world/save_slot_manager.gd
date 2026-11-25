extends RefCounted
class_name GhibliSaveSlotManager

const SAVE_PATH := "user://gta_ghibli_runtime_slots.cfg"
const SECTION := "slots"

var slots: Dictionary = {}


func save_slot(slot_id: String, payload: Dictionary, timestamp: int) -> bool:
	if slot_id.is_empty() or timestamp < 0:
		return false
	slots[slot_id] = {
		"payload": payload.duplicate(true),
		"timestamp": timestamp
	}
	return _write_slots()


func load_slot(slot_id: String) -> Dictionary:
	if slot_id.is_empty():
		return {}
	if not slots.has(slot_id):
		_read_slots()
	return slots.get(slot_id, {}).duplicate(true)


func delete_slot(slot_id: String) -> bool:
	if slot_id.is_empty():
		return false
	if not slots.has(slot_id):
		_read_slots()
	if not slots.erase(slot_id):
		return false
	return _write_slots()


func list_slots() -> Array[String]:
	_read_slots()
	var result: Array[String] = []
	for key in slots:
		result.append(str(key))
	result.sort()
	return result


func _read_slots() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	var stored: Variant = config.get_value(SECTION, "data", {})
	if stored is Dictionary:
		slots = stored.duplicate(true)


func _write_slots() -> bool:
	var config := ConfigFile.new()
	config.set_value(SECTION, "schema_version", 1)
	config.set_value(SECTION, "data", slots)
	return config.save(SAVE_PATH) == OK
