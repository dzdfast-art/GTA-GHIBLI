extends Node3D
const ANIMAL=preload("res://scripts/world/wildlife_actor.gd")
const VOICE=preload("res://scripts/audio/wildlife_voice.gd")
var _count:=0
var _counts:={}
func _ready()->void:
	_spawn("PineHighlands","deer","غزال",[Vector3(-13,0,4),Vector3(2,0,6),Vector3(14,0,2)],13,1.15,3.6,12)
	_spawn("AmberValley","rabbit","أرنب",[Vector3(-16,0,-12),Vector3(-8,0,-12),Vector3(1,0,-12),Vector3(9,0,-12),Vector3(16,0,-12)],8,0.95,3.4,9)
	_spawn("SapphireCoast","gull","نورس",[Vector3(-13,0,7),Vector3(-6,0,10),Vector3(7,0,10),Vector3(14,0,7)],10,1.3,3,12)
	_spawn("HarborCity","dog","كلب",[Vector3(-16,0,12),Vector3(15,0,-12)],6,1.25,3.8,10)
	_spawn("WillowVillage","cat","قط",[Vector3(-7,0,-6),Vector3(8,0,8)],5,0.8,2.8,8)
	_spawn("WillowVillage","chicken","دجاجة",[Vector3(1.5,0,30),Vector3(4,0,31),Vector3(7,0,30),Vector3(9,0,32)],3,0.45,2,5)
	_spawn("AmberValley","cow","بقرة",[Vector3(12,0,12)],4,0.45,2,7)
	_spawn("PineHighlands","horse","حصان",[Vector3(-10,0,-12)],7,1.1,3.3,10)
func get_wildlife_count()->int:
	return _count
func get_species_counts()->Dictionary:
	return _counts.duplicate(true)
func _spawn(region:String,species:String,name_ar:String,points:Array,roam:float,speed:float,flee:float,distance:float)->void:
	var habitat:Node3D
	if region=="WillowVillage":
		habitat=get_parent().get_node_or_null("WillowVillage") as Node3D
	else:
		habitat=get_parent().get_node_or_null("OpenWorldRegions/"+region) as Node3D
	if habitat==null:
		push_warning("Wildlife habitat missing: "+region)
		return
	for i in range(points.size()):
		var animal:=Node3D.new()
		animal.name="%s_%02d" % [species.capitalize(),i+1]
		animal.position=points[i]
		animal.set_script(ANIMAL)
		animal.set("species_id",species)
		animal.set("species_name_ar",name_ar)
		animal.set("roam_radius",roam)
		animal.set("walk_speed",speed)
		animal.set("flee_speed",flee)
		animal.set("flee_distance",distance)
		habitat.add_child(animal)
		var sound:=AudioStreamPlayer3D.new()
		sound.name="WildlifeVoice"
		sound.set_script(VOICE)
		sound.set("species_id",species)
		animal.add_child(sound)
		_count+=1
		_counts[species]=int(_counts.get(species,0))+1
