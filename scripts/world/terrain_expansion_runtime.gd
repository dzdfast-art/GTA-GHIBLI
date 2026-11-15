extends Node

## Attaches two original terrain meshes to each district.
## Visual chunks use distance visibility; collision baking and Android profiling remain separate tasks.
const REGIONAL_TILES := {
	"HarborCity": {
		"meshes": [preload("res://assets/environment/terrain/expansion_150mb/harbor_floodplain_west.obj"), preload("res://assets/environment/terrain/expansion_150mb/harbor_rail_flats.obj")],
		"positions": [Vector3(-29.0, 0.45, -42.0), Vector3(28.0, 0.45, 40.0)]
	},
	"PineHighlands": {
		"meshes": [preload("res://assets/environment/terrain/expansion_150mb/cedar_highlands_east.obj"), preload("res://assets/environment/terrain/expansion_150mb/pine_needle_uplands.obj")],
		"positions": [Vector3(-29.0, 0.45, -42.0), Vector3(28.0, 0.45, 40.0)]
	},
	"AmberValley": {
		"meshes": [preload("res://assets/environment/terrain/expansion_150mb/amber_valley_farm_basin.obj"), preload("res://assets/environment/terrain/expansion_150mb/orchard_terraces_north.obj")],
		"positions": [Vector3(-29.0, 0.45, -42.0), Vector3(28.0, 0.45, 40.0)]
	},
	"SapphireCoast": {
		"meshes": [preload("res://assets/environment/terrain/expansion_150mb/sapphire_coast_rock_shelf.obj"), preload("res://assets/environment/terrain/expansion_150mb/sapphire_tidal_flats.obj")],
		"positions": [Vector3(-29.0, 0.45, -42.0), Vector3(28.0, 0.45, 40.0)]
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
		var meshes: Array = tile_data["meshes"]
		var positions: Array = tile_data["positions"]
		for tile_index in range(meshes.size()):
			var tile := MeshInstance3D.new()
			tile.name = "ExpansionTerrain_%s_%02d" % [region_name, tile_index + 1]
			tile.mesh = meshes[tile_index] as Mesh
			tile.position = positions[tile_index]
			tile.scale = Vector3(0.18, 0.10, 0.18)
			tile.visibility_range_end = 220.0
			tile.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
			tile.add_to_group("world_terrain_chunks")
			district.add_child(tile)
			_attached_count += 1

func get_attached_count() -> int:
	return _attached_count
