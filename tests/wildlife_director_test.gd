extends SceneTree

const REGIONS_SCRIPT = preload("res://scripts/world/open_world_regions.gd")
const WILDLIFE_DIRECTOR_SCRIPT = preload("res://scripts/world/wildlife_director.gd")
const INVENTORY_SCRIPT = preload("res://scripts/systems/consumable_inventory.gd")

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var village := Node3D.new()
	village.name = "WillowVillage"
	world.add_child(village)
	var regions := Node3D.new()
	regions.name = "OpenWorldRegions"
	regions.set_script(REGIONS_SCRIPT)
	world.add_child(regions)
	var director := Node3D.new()
	director.set_script(WILDLIFE_DIRECTOR_SCRIPT)
	world.add_child(director)
	if int(director.call("get_wildlife_count")) != 22:
		_fail("Wildlife director did not create all habitat animals.")
		return
	var counts: Dictionary = director.call("get_species_counts")
	if int(counts.get("deer", 0)) != 3 or int(counts.get("rabbit", 0)) != 5 or int(counts.get("gull", 0)) != 4 or int(counts.get("dog", 0)) != 2 or int(counts.get("cat", 0)) != 2 or int(counts.get("chicken", 0)) != 4 or int(counts.get("cow", 0)) != 1 or int(counts.get("horse", 0)) != 1:
		_fail("The wildlife species population does not match the habitat plan.")
		return
	if village.get_node_or_null("Cat_01") == null or village.get_node_or_null("Chicken_01") == null:
		_fail("Village cats and chickens were not created.")
		return
	for region_name in ["PineHighlands", "AmberValley", "SapphireCoast", "HarborCity"]:
		var habitat := regions.get_node_or_null(region_name)
		if habitat == null or habitat.get_child_count() < 1:
			_fail("Wildlife habitat is missing: " + region_name)
			return
	var player := CharacterBody3D.new()
	player.name = "WildlifeTestPlayer"
	player.add_to_group("player")
	var inventory := Node.new()
	inventory.name = "ConsumableInventory"
	inventory.set_script(INVENTORY_SCRIPT)
	inventory.set("persistence_enabled", false)
	player.add_child(inventory)
	world.add_child(player)
	var rabbit := regions.get_node("AmberValley/Rabbit_01")
	if not inventory.call("add_item", "wild_berries", 2):
		_fail("Could not add wildlife food to player inventory.")
		return
	rabbit.call("_on_body_entered", player)
	rabbit.call("interact")
	rabbit.call("interact")
	if int(rabbit.get("bond_level")) != 2 or int(inventory.call("get_item_count", "wild_berries")) != 0:
		_fail("Feeding the rabbit did not consume two treats and improve its bond.")
		return
	player.global_position = rabbit.global_position
	rabbit.call("_find_player")
	if str(rabbit.call("get_wildlife_state")) != "following":
		_fail("A bonded rabbit did not enter the follow state.")
		return
	print("PASS: Three habitats populated, food consumed and a bonded rabbit follows the player.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
