extends SceneTree

## Physics-backed contract test for proximity detection and interaction dispatch.

const INTERACTOR_SCRIPT = preload("res://scripts/systems/player_interactor.gd")


class DummyInteractable:
	extends Node3D
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
	target.position = Vector3(0.0, 0.0, 2.0)
	root.add_child(target)

	var target_area := Area3D.new()
	target_area.name = "InteractionArea"
	target_area.collision_layer = 2
	target_area.collision_mask = 0
	target_area.add_to_group("interaction_areas")
	target.add_child(target_area)

	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 3.0
	collision.shape = sphere
	collision.position.y = 0.9
	target_area.add_child(collision)

	await physics_frame
	await physics_frame

	if not interactor.get("_nearby_areas").has(target_area):
		_fail("The player detector did not register a nearby interaction area.")
		return

	interactor.call("_interact_with_nearest")
	if target.interaction_count != 1:
		_fail("The nearest interactable did not receive exactly one interaction.")
		return

	var invalid_target := Node.new()
	root.add_child(invalid_target)
	if bool(interactor.call("try_interact", invalid_target)):
		_fail("The shared interactor accepted a node without interact().")
		return

	print("PASS: proximity detection finds an interactable and dispatches one interaction.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
