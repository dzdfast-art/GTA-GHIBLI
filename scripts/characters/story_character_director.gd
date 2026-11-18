extends Node3D
const NPC = preload("res://scripts/characters/world_npc_actor.gd")
var _count := 0

func _ready() -> void:
	_spawn("NoraBlake","OpenWorldRegions/HarborCity","nora_blake",Vector3(-1,0,3),Color(0.23,0.32,0.43),Color(0.78,0.59,0.47),Color(0.12,0.09,0.08))
	_spawn("MiaBennett","WillowVillage","mia_bennett",Vector3(5,0,-3),Color(0.36,0.54,0.78),Color(0.86,0.67,0.54),Color(0.30,0.18,0.12))
	_spawn("ClaireBennett","WillowVillage","claire_bennett",Vector3(-7,0,8),Color(0.54,0.37,0.32),Color(0.83,0.64,0.52),Color(0.35,0.25,0.19))
	_spawn("TheBroker","OpenWorldRegions/HarborCity","the_broker",Vector3(15,0,5),Color(0.10,0.12,0.16),Color(0.65,0.48,0.39),Color(0.07,0.06,0.06))
	_spawn("ThomasBennettMemory","OpenWorldRegions/HarborCity","thomas_bennett",Vector3(18,0,13),Color(0.40,0.37,0.30),Color(0.73,0.54,0.43),Color(0.22,0.17,0.13),true)

func get_spawned_count()->int:
	return _count

func _spawn(n:String,parent_path:String,id:String,at:Vector3,outfit:Color,skin:Color,hair:Color,hidden:=false)->void:
	var parent:=get_parent().get_node_or_null(parent_path) as Node3D
	if parent==null:
		push_warning("Story character location missing: "+parent_path)
		return
	var actor:=Node3D.new()
	actor.name=n
	actor.position=at
	actor.add_to_group("story_characters")
	actor.set_script(NPC)
	actor.set("character_id",id)
	actor.set("outfit_color",outfit)
	actor.set("skin_color",skin)
	actor.set("hair_color",hair)
	actor.set("hidden_story_character",hidden)
	parent.add_child(actor)
	_count+=1
