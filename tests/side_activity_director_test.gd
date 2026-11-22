extends SceneTree

## Headless regression for side-activity restart and reward idempotency.
const DIRECTOR_SCRIPT = preload("res://scripts/world/side_activity_director.gd")
const WALLET_SCRIPT = preload("res://scripts/systems/player_wallet.gd")
const TEST_SAVE_PATH := "user://gta_ghibli_side_activity_regression.json"

var _preserved_save := ""
var _had_save := false


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	_preserve_test_save()
	_remove_test_save()
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
	director.set("save_path_override", TEST_SAVE_PATH)
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

	var active_snapshot: Dictionary = director.get_save_snapshot()
	for marker in director._target_nodes:
		if is_instance_valid(marker):
			marker.queue_free()
	director._target_nodes.clear()
	if not director.apply_save_snapshot(active_snapshot):
		_fail("The active side activity snapshot must restore.")
		return
	if director._target_nodes.size() != 1 or director._target_nodes[0].visible or director._targets_found != 1:
		_fail("Restart must recreate the collected target as hidden and preserve objective progress.")
		return

	player.global_position = Vector3(-14.0, 0.0, -12.0)
	director._physics_process(0.0)
	if not director._completed_ids.has("lost_delivery") or director._total_rewards != 80:
		_fail("Returning after resume did not complete the activity exactly once.")
		return
	if int(wallet.call("get_balance")) != 180:
		_fail("Side activity reward was not transferred to the player wallet.")
		return
	if director.call("_complete_activity", director.call("_activity_by_id", "lost_delivery")):
		_fail("A completed side activity must reject a second completion.")
		return
	if int(wallet.call("get_balance")) != 180 or director._total_rewards != 80:
		_fail("A duplicate completion must not add money or inflate the reward total.")
		return

	director._active_id = "farmer_crates"
	var farmer_activity: Dictionary = director.call("_activity_by_id", "farmer_crates")
	if not wallet.call("add_money_once", "side_activity_farmer_crates_completion", 120):
		_fail("The simulated pre-committed farmer reward must be accepted.")
		return
	var balance_after_precommit := int(wallet.call("get_balance"))
	if not director.call("_complete_activity", farmer_activity):
		_fail("The resumed activity must recognize its already-paid transaction and complete.")
		return
	if int(wallet.call("get_balance")) != balance_after_precommit:
		_fail("Recovering a pre-paid activity must not pay its reward a second time.")
		return
	if director._total_rewards != 200 or not director._completed_ids.has("farmer_crates"):
		_fail("Recovered activity completion must update the completion ledger exactly once.")
		return
	if director.call("_complete_activity", farmer_activity):
		_fail("The recovered activity must reject a second completion.")
		return
	if int(wallet.call("get_balance")) != balance_after_precommit or director._total_rewards != 200:
		_fail("Repeated recovered completion must not duplicate currency or reward totals.")
		return

	director.queue_free()
	world.queue_free()
	await process_frame
	_restore_test_save()
	print("PASS: side activity target restore, progress persistence, idempotent rewards and interrupted-completion recovery.")
	quit(0)


func _preserve_test_save() -> void:
	_had_save = FileAccess.file_exists(TEST_SAVE_PATH)
	if not _had_save:
		return
	var file := FileAccess.open(TEST_SAVE_PATH, FileAccess.READ)
	if file != null:
		_preserved_save = file.get_as_text()
		file.close()


func _remove_test_save() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))


func _restore_test_save() -> void:
	_remove_test_save()
	if not _had_save:
		return
	var file := FileAccess.open(TEST_SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(_preserved_save)
		file.flush()
		file.close()


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	_restore_test_save()
	quit(1)
