extends SceneTree

const WALLET_SCRIPT = preload("res://scripts/systems/player_wallet.gd")
const INVENTORY_SCRIPT = preload("res://scripts/systems/consumable_inventory.gd")
const SHOP_SCRIPT = preload("res://scripts/world/consumable_shop.gd")

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var player := CharacterBody3D.new()
	player.name = "ShopTestPlayer"
	player.add_to_group("player")
	root.add_child(player)
	var wallet := Node.new()
	wallet.name = "PlayerWallet"
	wallet.set_script(WALLET_SCRIPT)
	wallet.set("persistence_enabled", false)
	wallet.set("initial_balance", 100)
	player.add_child(wallet)
	var inventory := Node.new()
	inventory.name = "ConsumableInventory"
	inventory.set_script(INVENTORY_SCRIPT)
	inventory.set("persistence_enabled", false)
	player.add_child(inventory)
	var shop := Node3D.new()
	shop.set_script(SHOP_SCRIPT)
	root.add_child(shop)
	shop.set("_player_nearby", true)
	shop.call("_buy_item", "village_bread")
	if int(wallet.call("get_balance")) != 85:
		_fail("Buying bread did not deduct the correct amount.")
		return
	if int(inventory.call("get_item_count", "village_bread")) != 1:
		_fail("Purchased bread was not added to inventory.")
		return
	shop.call("_buy_item", "field_meal")
	if int(wallet.call("get_balance")) != 60:
		_fail("Buying a second item did not correctly update the wallet.")
		return
	shop.call("_buy_item", "unknown")
	if int(wallet.call("get_balance")) != 60:
		_fail("Unknown product changed the wallet balance.")
		return
	print("PASS: Village shop purchases, inventory delivery and wallet deductions.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
