extends RefCounted
class_name GhibliSaveSlotManager
var slots: Dictionary = {}
func save_slot(slot_id: String, payload: Dictionary, timestamp: int) -> bool:
	if slot_id.is_empty() or timestamp < 0: return false
	slots[slot_id]={"payload":payload.duplicate(true),"timestamp":timestamp}
	return true
func load_slot(slot_id: String) -> Dictionary:
	return slots.get(slot_id,{}).duplicate(true)
func delete_slot(slot_id: String) -> bool:
	return slots.erase(slot_id)
func list_slots() -> Array[String]:
	var result: Array[String]=[]
	for key in slots: result.append(str(key))
	result.sort()
	return result