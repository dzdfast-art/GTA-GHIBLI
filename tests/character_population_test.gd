extends SceneTree
const REGION=preload("res://scripts/world/open_world_regions.gd")
const STORY=preload("res://scripts/characters/story_character_director.gd")
func _initialize()->void:
	call_deferred("_run")
func _run()->void:
	var world:=Node3D.new()
	root.add_child(world)
	var village:=Node3D.new()
	village.name="WillowVillage"
	world.add_child(village)
	var regions:=Node3D.new()
	regions.name="OpenWorldRegions"
	regions.set_script(REGION)
	world.add_child(regions)
	var player:=CharacterBody3D.new()
	player.add_to_group("player")
	world.add_child(player)
	var director:=Node3D.new()
	director.set_script(STORY)
	world.add_child(director)
	await process_frame
	if int(director.call("get_spawned_count"))!=5:
		_fail("Expected five additional story characters.")
		return
	if get_nodes_in_group("civilian_npcs").size()!=8:
		_fail("Expected eight named secondary NPCs.")
		return
	for actor in get_nodes_in_group("civilian_npcs"):
		if actor.get_node_or_null("InteractionArea")==null or actor.get_node_or_null("NPCBrain")==null:
			_fail("Secondary NPC missing interaction or NPC brain.")
			return
	print("PASS: five story cast actors and eight named interactive civilians.")
	quit(0)
func _fail(message:String)->void:
	push_error("FAIL: "+message)
	quit(1)
