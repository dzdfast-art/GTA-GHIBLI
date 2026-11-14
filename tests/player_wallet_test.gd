extends SceneTree

const WALLET_SCRIPT = preload("res://scripts/systems/player_wallet.gd")

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var wallet := Node.new()
	wallet.set_script(WALLET_SCRIPT)
	wallet.set("persistence_enabled", false)
	wallet.set("initial_balance", 100)
	root.add_child(wallet)
	if int(wallet.call("get_balance")) != 100:
		_fail("Wallet did not start with its configured balance.")
		return
	if not wallet.call("spend_money", 35):
		_fail("Wallet rejected a purchase the player could afford.")
		return
	if int(wallet.call("get_balance")) != 65:
		_fail("Wallet balance did not decrease after purchase.")
		return
	if wallet.call("spend_money", 66):
		_fail("Wallet allowed spending more money than available.")
		return
	if not wallet.call("add_money", 40) or int(wallet.call("get_balance")) != 105:
		_fail("Wallet did not add an earned reward.")
		return
	print("PASS: Wallet balance, purchase limits and earned rewards.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
