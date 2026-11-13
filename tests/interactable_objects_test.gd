extends SceneTree

const DOOR_SCRIPT = preload("res://scripts/systems/interactable_door.gd")
const PROP_SCRIPT = preload("res://scripts/systems/carryable_prop.gd")


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var door := Node3D.new()
	door.set_script(DOOR_SCRIPT)
	root.add_child(door)
	if door.is_open:
		_fail("Door should begin closed.")
		return
	door.interact()
	if not door.is_open:
		_fail("Door did not switch to open state.")
		return
	door.interact()
	if door.is_open:
		_fail("Door did not switch back to closed state.")
		return

	var player := CharacterBody3D.new()
	player.name = "Player"
	player.add_to_group("player")
	root.add_child(player)
	var prop := RigidBody3D.new()
	prop.set_script(PROP_SCRIPT)
	root.add_child(prop)
	prop.interact()
	if not prop.is_carried:
		_fail("Carryable prop did not enter carried state.")
		return
	prop.interact()
	if prop.is_carried:
		_fail("Carryable prop did not drop.")
		return

	print("PASS: door state toggles and carryable prop can be picked up and dropped.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
