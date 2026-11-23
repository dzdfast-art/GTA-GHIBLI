extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/save_slot_manager.gd").new()
		assert(m.save_slot("one",{"cash":50},100))
		assert(m.load_slot("one").payload.cash==50)
		assert(m.list_slots().has("one"))
		assert(m.delete_slot("one") and m.load_slot("one").is_empty())
	print("PASS: Save Slot Manager.")
	quit(0)
