extends RefCounted
## Lightweight, original, tileable 512px surface library for the four open-world biomes.
const TEXTURES := {
	"asphalt": [
		preload("res://assets/environment/surfaces/asphalt_01_512.png"),
		preload("res://assets/environment/surfaces/asphalt_02_512.png"),
		preload("res://assets/environment/surfaces/asphalt_03_512.png"),
		preload("res://assets/environment/surfaces/asphalt_04_512.png")
	],
	"sandstone": [
		preload("res://assets/environment/surfaces/sandstone_01_512.png"),
		preload("res://assets/environment/surfaces/sandstone_02_512.png"),
		preload("res://assets/environment/surfaces/sandstone_03_512.png"),
		preload("res://assets/environment/surfaces/sandstone_04_512.png")
	],
	"pine": [
		preload("res://assets/environment/surfaces/pine_01_512.png"),
		preload("res://assets/environment/surfaces/pine_02_512.png"),
		preload("res://assets/environment/surfaces/pine_03_512.png"),
		preload("res://assets/environment/surfaces/pine_04_512.png")
	],
	"sand": [
		preload("res://assets/environment/surfaces/sand_01_512.png"),
		preload("res://assets/environment/surfaces/sand_02_512.png"),
		preload("res://assets/environment/surfaces/sand_03_512.png"),
		preload("res://assets/environment/surfaces/sand_04_512.png")
	],
	"wood": [
		preload("res://assets/environment/surfaces/wood_01_512.png"),
		preload("res://assets/environment/surfaces/wood_02_512.png"),
		preload("res://assets/environment/surfaces/wood_03_512.png"),
		preload("res://assets/environment/surfaces/wood_04_512.png")
	],
	"concrete": [
		preload("res://assets/environment/surfaces/concrete_01_512.png"),
		preload("res://assets/environment/surfaces/concrete_02_512.png"),
		preload("res://assets/environment/surfaces/concrete_03_512.png"),
		preload("res://assets/environment/surfaces/concrete_04_512.png")
	]
}

static func make_material(surface: String, variant: int = 0, tint: Color = Color.WHITE) -> StandardMaterial3D:
	var choices: Array = TEXTURES.get(surface, TEXTURES["concrete"])
	var material := StandardMaterial3D.new()
	material.albedo_texture = choices[posmod(variant, choices.size())] as Texture2D
	material.albedo_color = tint
	material.roughness = 0.92
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	material.uv1_scale = Vector3(3.0, 3.0, 3.0)
	return material
