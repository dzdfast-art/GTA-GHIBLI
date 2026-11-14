extends Node3D

## Places original low-poly prototype wildlife in three habitats.
const WILDLIFE_SCRIPT = preload("res://scripts/world/wildlife_actor.gd")

var _wildlife_count := 0
var _species_counts := {}

func _ready() -> void:
	_spawn_group("PineHighlands", "deer", "غزال", [
		Vector3(-13.0, 0.0, 4.0),
		Vector3(2.0, 0.0, 6.0),
		Vector3(14.0, 0.0, 2.0)
	], 13.0, 1.15, 3.6, 12.0)
	_spawn_group("AmberValley", "rabbit", "أرنب", [
		Vector3(-16.0, 0.0, -12.0),
		Vector3(-8.0, 0.0, -12.0),
		Vector3(1.0, 0.0, -12.0),
		Vector3(9.0, 0.0, -12.0),
		Vector3(16.0, 0.0, -12.0)
	], 8.0, 0.95, 3.4, 9.0)
	_spawn_group("SapphireCoast", "gull", "نورس", [
		Vector3(-13.0, 0.0, 7.0),
		Vector3(-6.0, 0.0, 10.0),
		Vector3(7.0, 0.0, 10.0),
		Vector3(14.0, 0.0, 7.0)
	], 10.0, 1.3, 3.0, 12.0)

func get_wildlife_count() -> int:
	return _wildlife_count

func get_species_counts() -> Dictionary:
	return _species_counts.duplicate(true)

func _spawn_group(region_node_name: String, species: String, name_ar: String, positions: Array,
		roam: float, speed: float, flee_speed: float, flee_distance: float) -> void:
	var habitat := get_parent().get_node_or_null("OpenWorldRegions/" + region_node_name) as Node3D
	if habitat == null:
		push_warning("Wildlife habitat is missing: " + region_node_name)
		return
	for index in range(positions.size()):
		var animal := Node3D.new()
		animal.name = "%s_%02d" % [species.capitalize(), index + 1]
		animal.position = positions[index]
		animal.set_script(WILDLIFE_SCRIPT)
		animal.set("species_id", species)
		animal.set("species_name_ar", name_ar)
		animal.set("roam_radius", roam)
		animal.set("walk_speed", speed)
		animal.set("flee_speed", flee_speed)
		animal.set("flee_distance", flee_distance)
		animal.set("follow_distance", 7.0)
		habitat.add_child(animal)
		_wildlife_count += 1
		_species_counts[species] = int(_species_counts.get(species, 0)) + 1
