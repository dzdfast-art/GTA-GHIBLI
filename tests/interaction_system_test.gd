extends SceneTree

## Contract test: the shared player interactor calls valid targets and rejects invalid ones.

const INTERACTOR_SCRIPT = preload("res://scripts/systems/player_interactor.gd")


class DummyInteractable:
	extends Node
	var interaction_count := 0

	func interact() -> void:
		interaction_count += 1


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var actor := Node3D.new()
	root.add_child(actor)

	var interactor := Node.new()
	interactor.set_script(INTERACTOR_SCRIPT)
	actor.add_child(interactor)

	var target := DummyInteractable.new()
	root.add_child(target)

	if not interactor.try_interact(target):
		_fail("The shared interactor rejected a valid interactable target.")
		return
	if target.interaction_count != 1:
		_fail("The target did not receive exactly one interaction call.")
		return

	var invalid_target := Node.new()
	root.add_child(invalid_target)
	if interactor.try_interact(invalid_target):
		_fail("The shared interactor accepted a node without interact().")
		return

	print("PASS: shared interaction contract calls valid targets and rejects invalid targets.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
