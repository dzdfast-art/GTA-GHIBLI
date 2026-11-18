extends SceneTree

const WALLET_SCRIPT = preload("res://scripts/systems/player_wallet.gd")

func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var wallet: Node = WALLET_SCRIPT.new()
	wallet.set("persistence_enabled", false)
	wallet.set("initial_balance", 100)
	root.add_child(wallet)

	if not bool(wallet.call("claim_reward", "campaign_reward_test_mission", 25)):
		_fail("The first mission reward was not accepted.")
		return
	if int(wallet.call("get_balance")) != 125:
		_fail("The reward did not increase the wallet balance.")
		return
	if bool(wallet.call("claim_reward", "campaign_reward_test_mission", 25)):
		_fail("The same reward identifier was paid more than once.")
		return
	if int(wallet.call("get_balance")) != 125:
		_fail("A duplicate reward changed the wallet balance.")
		return

	print("PASS: mission rewards are added once per stable reward id.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
