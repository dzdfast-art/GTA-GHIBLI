extends SceneTree

const NEEDS_SCRIPT = preload("res://scripts/systems/player_needs.gd")
const INVENTORY_SCRIPT = preload("res://scripts/systems/consumable_inventory.gd")

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var player := Node3D.new()
	player.name = "InventoryTestPlayer"
	root.add_child(player)
	var needs := Node.new()
	needs.name = "PlayerNeeds"
	needs.set_script(NEEDS_SCRIPT)
	needs.set("persistence_enabled", false)
	needs.set("hunger", 40.0)
	needs.set("thirst", 30.0)
	needs.set("energy", 40.0)
	player.add_child(needs)
	var inventory := Node.new()
	inventory.set_script(INVENTORY_SCRIPT)
	inventory.set("persistence_enabled", false)
	player.add_child(inventory)
	if inventory.call("get_catalog_ids").is_empty():
		_fail("Consumables catalog did not load.")
		return
	if not inventory.call("add_item", "village_bread", 2):
		_fail("Could not add catalog item.")
		return
	if int(inventory.call("get_item_count", "village_bread")) != 2:
		_fail("Inventory count did not increase.")
		return
	if not inventory.call("consume_item", "village_bread"):
		_fail("Could not consume food.")
		return
	if int(inventory.call("get_item_count", "village_bread")) != 1:
		_fail("Consuming food did not reduce inventory.")
		return
	if float(needs.get("hunger")) <= 40.0 or float(needs.get("thirst")) <= 30.0:
		_fail("Food did not restore player needs.")
		return
	if not inventory.call("add_item", "water_bottle", 1):
		_fail("Could not add water.")
		return
	var thirst_before := float(needs.get("thirst"))
	if not inventory.call("consume_item", "water_bottle"):
		_fail("Could not drink water.")
		return
	if float(needs.get("thirst")) <= thirst_before:
		_fail("Drinking did not restore thirst.")
		return
	if inventory.call("consume_item", "unknown_item"):
		_fail("Unknown item was incorrectly consumed.")
		return
	print("PASS: Consumables catalog, inventory counts, food and drink effects.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
