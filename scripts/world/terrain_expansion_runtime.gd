extends Node

## Adds one regional expansion mesh to each district.
## Visual-only prototype: collision baking and Android profiling remain separate tasks.
const REGIONAL_TILES := {
	"HarborCity": {
		"mesh": preload("res://assets/environment/terrain/expansion_150mb/harbor_floodplain_west.obj"),
		"position": Vector3(-29.0, 0.45, -42.0)
	},
	"PineHighlands": {
		"mesh": preload("res://assets/environment/terrain/expansion_150mb/cedar_highlands_east.obj"),
		"position": Vector3(-29.0, 0.45, -42.0)
	},
	"AmberValley": {
		"mesh": preload("res://assets/environment/terrain/expansion_150mb/amber_valley_farm_basin.obj"),
		"position": Vector3(-29.0, 0.45, -42.0)
	},
	"SapphireCoast": {
		"mesh": preload("res://assets/environment/terrain/expansion_150mb/sapphire_coast_rock_shelf.obj"),
		"position": Vector3(-29.0, 0.45, -42.0)
	}
}

var _attached_count := 0

func _ready() -> void:
	var regions := get_parent().get_node_or_null("OpenWorldRegions")
	if regions == null:
		push_warning("Terrain expansion: OpenWorldRegions node was not found.")
		return
	for region_name in REGIONAL_TILES:
		var district := regions.get_node_or_null(region_name) as Node3D
		if district == null:
			push_warning("Terrain expansion: missing district " + region_name)
			continue
		var tile_data: Dictionary = REGIONAL_TILES[region_name]
		var tile := MeshInstance3D.new()
		tile.name = "ExpansionTerrain_" + region_name
		tile.mesh = tile_data["mesh"] as Mesh
		tile.position = tile_data["position"]
		tile.scale = Vector3(0.18, 0.10, 0.18)
		tile.visibility_range_end = 220.0
		tile.add_to_group("world_terrain_chunks")
		district.add_child(tile)
		_attached_count += 1

func get_attached_count() -> int:
	return _attached_count
