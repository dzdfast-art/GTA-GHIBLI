extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/shop_inventory.gd").new()
		assert(m.add_item("water",5,3))
		var p=m.purchase("water",20,2)
		assert(p.ok and p.wallet==10)
		assert(m.purchase("water",20,2).reason=="out_of_stock")
		assert(m.purchase("water",1,1).reason=="insufficient_funds")
	print("PASS: Shop Inventory and Purchase.")
	quit(0)
