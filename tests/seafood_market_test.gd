extends SceneTree

const MARKET_SCENE = preload("res://scenes/world/seafood_market.tscn")
const WALLET_SCRIPT = preload("res://scripts/systems/player_wallet.gd")
const INVENTORY_SCRIPT = preload("res://scripts/systems/consumable_inventory.gd")
const NEEDS_SCRIPT = preload("res://scripts/systems/player_needs.gd")


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var player := CharacterBody3D.new()
	player.name = "SeafoodMarketTestPlayer"
	player.add_to_group("player")
	root.add_child(player)

	var wallet := Node.new()
	wallet.name = "PlayerWallet"
	wallet.set_script(WALLET_SCRIPT)
	wallet.set("persistence_enabled", false)
	wallet.set("initial_balance", 100)
	player.add_child(wallet)

	var needs := Node.new()
	needs.name = "PlayerNeeds"
	needs.set_script(NEEDS_SCRIPT)
	needs.set("persistence_enabled", false)
	needs.set("hunger", 30.0)
	needs.set("thirst", 25.0)
	needs.set("energy", 20.0)
	player.add_child(needs)

	var inventory := Node.new()
	inventory.name = "ConsumableInventory"
	inventory.set_script(INVENTORY_SCRIPT)
	inventory.set("persistence_enabled", false)
	player.add_child(inventory)

	var market := MARKET_SCENE.instantiate()
	root.add_child(market)
	var stall := market.get_node_or_null("StallVisual") as MeshInstance3D
	var display := market.get_node_or_null("SeafoodDisplay") as MeshInstance3D
	if stall == null or stall.mesh == null:
		_fail("The original market stall mesh did not load.")
		return
	if display == null or display.mesh == null or display.mesh.get_surface_count() < 6:
		_fail("The seafood display must load its six original material surfaces.")
		return

	var ids: PackedStringArray = inventory.call("get_catalog_ids")
	for item_id in ["grilled_sardines", "seafood_stew", "red_mullet_plate"]:
		if not ids.has(item_id):
			_fail("Seafood product is missing from the consumables catalogue: " + item_id)
			return

	market.set("_player_nearby", true)
	var purchases: Array = []
	market.purchase_completed.connect(func(item_id: String, balance: int): purchases.append([item_id, balance]))
	market.call("_buy_item", "grilled_sardines")
	if int(wallet.call("get_balance")) != 78 or int(inventory.call("get_item_count", "grilled_sardines")) != 1:
		_fail("The fish market purchase did not update wallet and inventory.")
		return
	if purchases.size() != 1 or str(purchases[0][0]) != "grilled_sardines":
		_fail("The fish market did not emit its purchase-completed signal.")
		return

	var hunger_before := float(needs.get("hunger"))
	if not inventory.call("consume_item", "grilled_sardines"):
		_fail("The purchased grilled sardines could not be consumed.")
		return
	if float(needs.get("hunger")) <= hunger_before:
		_fail("The seafood meal did not restore player hunger.")
		return
	if int(inventory.call("get_item_count", "grilled_sardines")) != 0:
		_fail("Consuming the seafood meal did not decrement inventory.")
		return

	market.call("_buy_item", "unknown_seafood")
	if int(wallet.call("get_balance")) != 78:
		_fail("An unknown product changed the player balance.")
		return
	market.set("_player_nearby", false)
	market.call("_buy_item", "seafood_stew")
	if int(wallet.call("get_balance")) != 78:
		_fail("A player outside vendor range was allowed to buy.")
		return
	market.set("_player_nearby", true)
	wallet.call("spend_money", 60)
	market.call("_buy_item", "red_mullet_plate")
	if int(wallet.call("get_balance")) != 18:
		_fail("An unaffordable purchase changed the balance.")
		return

	print("PASS: Seafood market import, catalogue, purchases, wallet, inventory, food use and guards.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
