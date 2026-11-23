extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/weapon_inventory.gd").new()
		assert(m.add_weapon("pistol",5))
		assert(m.consume_ammo(2) and m.ammo_count("pistol")==3)
		assert(not m.consume_ammo(10))
		assert(not m.select_weapon("missing"))
	print("PASS: Weapon Inventory.")
	quit(0)
