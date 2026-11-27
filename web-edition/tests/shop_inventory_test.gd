extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var shop: RefCounted = load("res://scripts/world/shop_inventory.gd").new()
	assert(shop.call("add_item", "water", 5, 3))

	var bought: Dictionary = shop.call("purchase", "water", 20, 2)
	assert(bool(bought.get("ok", false)))
	assert(int(bought.get("wallet", -1)) == 10)
	assert(shop.call("get_quantity", "water") == 2)
	assert(int(shop.get("stock").water.quantity) == 1)

	var before_failed_purchase: Dictionary = shop.call("snapshot")
	var out_of_stock: Dictionary = shop.call("purchase", "water", 100, 2)
	assert(not bool(out_of_stock.get("ok", true)))
	assert(str(out_of_stock.get("reason", "")) == "out_of_stock")
	var insufficient: Dictionary = shop.call("purchase", "water", 1, 1)
	assert(not bool(insufficient.get("ok", true)))
	assert(str(insufficient.get("reason", "")) == "insufficient_funds")
	assert(shop.call("snapshot") == before_failed_purchase)

	var sold: Dictionary = shop.call("sell", "water", 10, 1)
	assert(bool(sold.get("ok", false)))
	assert(int(sold.get("wallet", -1)) == 12)
	assert(int(sold.get("proceeds", -1)) == 2)
	assert(shop.call("get_quantity", "water") == 1)
	assert(int(shop.get("stock").water.quantity) == 2)

	var saved: Dictionary = shop.call("snapshot")
	var restored: RefCounted = load("res://scripts/world/shop_inventory.gd").new()
	assert(restored.call("add_item", "water", 5, 3))
	assert(restored.call("restore", saved))
	assert(restored.call("snapshot") == saved)

	var invalid_snapshot: Dictionary = saved.duplicate(true)
	invalid_snapshot.stock.water.price = 99
	assert(not bool(restored.call("restore", invalid_snapshot)))

	var reset_shop: RefCounted = load("res://scripts/world/shop_inventory.gd").new()
	assert(reset_shop.call("add_item", "water", 5, 3))
	reset_shop.call("purchase", "water", 20, 2)
	reset_shop.call("reset")
	assert(reset_shop.call("get_quantity", "water") == 0)
	assert(int(reset_shop.get("stock").water.quantity) == 3)

	print("PASS: shop purchases, stock, player inventory, insufficient funds, sell-back value, validated save restore and reset.")
	quit(0)
