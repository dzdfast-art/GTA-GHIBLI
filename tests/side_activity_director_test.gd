extends SceneTree

## Headless test for a complete optional side activity.
const DIRECTOR_SCRIPT = preload("res://scripts/world/side_activity_director.gd")
const WALLET_SCRIPT = preload("res://scripts/systems/player_wallet.gd")


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var world := Node3D.new()
	world.name = "SideActivityTestWorld"
	root.add_child(world)
	var player := CharacterBody3D.new()
	player.name = "SideActivityTestPlayer"
	world.add_child(player)
	var wallet := Node.new()
	wallet.name = "PlayerWallet"
	wallet.set_script(WALLET_SCRIPT)
	wallet.set("persistence_enabled", false)
	wallet.set("initial_balance", 100)
	player.add_child(wallet)
	var director: CanvasLayer = DIRECTOR_SCRIPT.new() as CanvasLayer
	root.add_child(director)
	director._world_root = world
	director.setup(player)
	director._ensure_world_content()

	player.global_position = Vector3(-14.0, 0.0, -12.0)
	director._physics_process(0.0)
	if not director._accept_button.visible:
		_fail("The nearby lost-delivery activity was not offered.")
		return

	director._on_accept_pressed()
	if director._active_id != "lost_delivery" or director._target_nodes.size() != 1:
		_fail("Accepting the lost-delivery activity did not create its objective.")
		return

	player.global_position = director._target_nodes[0].global_position
	director._physics_process(0.0)
	if director._targets_found != 1:
		_fail("Collecting the lost package did not complete the pickup objective.")
		return

	player.global_position = Vector3(-14.0, 0.0, -12.0)
	director._physics_process(0.0)
	if not director._completed_ids.has("lost_delivery") or director._total_rewards != 80:
		_fail("Returning the package did not save the activity and reward.")
		return
	if int(wallet.call("get_balance")) != 180:
		_fail("Side activity reward was not transferred to the player wallet.")
		return

	print("PASS: Side activity offer, pickup, return and reward.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
