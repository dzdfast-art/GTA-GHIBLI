extends SceneTree

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const PORTAL_SCRIPT = preload("res://scripts/world/house_interior_portal.gd")


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var player := PLAYER_SCENE.instantiate() as CharacterBody3D
	player.name = "Player"
	player.add_to_group("player")
	player.position = Vector3(0.0, 0.95, 0.0)
	root.add_child(player)

	var portal := Node3D.new()
	portal.set_script(PORTAL_SCRIPT)
	root.add_child(portal)
	await process_frame

	var outside_transform := player.global_transform
	portal.call("interact")
	if not bool(portal.get("_is_inside")):
		_fail("The house portal did not enter the interior state.")
		return
	if player.global_position.y > -40.0:
		_fail("The player was not moved into the interior room.")
		return

	portal.call("interact")
	if bool(portal.get("_is_inside")):
		_fail("The house portal did not return to the exterior state.")
		return
	if player.global_transform.origin.distance_to(outside_transform.origin) > 0.1:
		_fail("The exterior player transform was not restored.")
		return

	print("PASS: red house marker portal enters a furnished interior and returns outside.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
