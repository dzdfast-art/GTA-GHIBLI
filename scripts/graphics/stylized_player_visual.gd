extends MeshInstance3D

const WHITE_TANK_TEXTURE: Texture2D = preload("res://assets/characters/materials/ghibli_white_tank_fabric.svg")
const BLUE_DENIM_TEXTURE: Texture2D = preload("res://assets/characters/materials/ghibli_blue_denim.svg")
const PBR_HERO_SCENE: PackedScene = preload("res://assets/characters/models/ghibli_hero.gltf")

## Procedural, original third-person character art for the Android prototype.
## The parent Visual node remains the visibility switch used by vehicle enter/exit.

var _arm_pivots: Array[Node3D] = []
var _leg_pivots: Array[Node3D] = []
var _walk_clock := 0.0
var _attack_remaining := 0.0


func _ready() -> void:
	mesh = null
	# The gameplay capsule is centered on the player origin; align the model feet
	# with the capsule bottom instead of placing the model above the collision.
	position.y = -0.9
	_build_character()


func _process(delta: float) -> void:
	var player := get_parent() as CharacterBody3D
	if player == null:
		return
	_walk_clock += delta
	var speed := Vector2(player.velocity.x, player.velocity.z).length()
	var swing := sin(_walk_clock * 9.0) * clampf(speed / 3.2, 0.0, 1.0) * 0.42
	if Input.is_action_just_pressed("attack"):
		_attack_remaining = 0.26
	if _attack_remaining > 0.0:
		_attack_remaining = maxf(0.0, _attack_remaining - delta)
	if _arm_pivots.size() == 2:
		_arm_pivots[0].rotation.x = swing
		_arm_pivots[1].rotation.x = lerpf(-swing, 1.18, clampf(_attack_remaining / 0.26, 0.0, 1.0)) if _attack_remaining > 0.0 else -swing
	if _leg_pivots.size() == 2:
		_leg_pivots[0].rotation.x = -swing * 0.82
		_leg_pivots[1].rotation.x = swing * 0.82


func _build_character() -> void:
	if PBR_HERO_SCENE != null:
		var imported_hero := PBR_HERO_SCENE.instantiate() as Node3D
		if imported_hero != null:
			imported_hero.name = "PBR_GhibliHero"
			add_child(imported_hero)
			_arm_pivots.clear()
			_leg_pivots.clear()
			for pivot_name in ["ArmPivot_Left", "ArmPivot_Right"]:
				var pivot := _find_named_node(imported_hero, pivot_name) as Node3D
				if pivot != null:
					_arm_pivots.append(pivot)
			for pivot_name in ["LegPivot_Left", "LegPivot_Right"]:
				var pivot := _find_named_node(imported_hero, pivot_name) as Node3D
				if pivot != null:
					_leg_pivots.append(pivot)
			if _arm_pivots.size() == 2 and _leg_pivots.size() == 2:
				_apply_imported_hero_materials(imported_hero)
				_add_back_logo()
				return
			push_warning("Imported Ghibli hero is missing articulated pivots; using fallback visual. Arms=%d Legs=%d" % [_arm_pivots.size(), _leg_pivots.size()])
			_print_imported_node_tree(imported_hero)
			imported_hero.queue_free()
		else:
			push_warning("Imported Ghibli hero could not be instantiated; using fallback visual.")
	_build_fallback_character()


func _find_named_node(parent: Node, target_name: String) -> Node:
	for child in parent.get_children():
		if str(child.name) == target_name:
			return child
		var nested := _find_named_node(child, target_name)
		if nested != null:
			return nested
	return null


func _print_imported_node_tree(parent: Node, prefix: String = "") -> void:
	for child in parent.get_children():
		print("PBR_HERO_NODE:", prefix + str(child.name), " [", child.get_class(), "]")
		_print_imported_node_tree(child, prefix + str(child.name) + "/")


func _apply_imported_hero_materials(hero: Node3D) -> void:
	# The reference protagonist wears a white sleeveless shirt, blue jeans and
	# dark shoes. Keep the original imported geometry but remove hoodie layers.
	var tank_material := StandardMaterial3D.new()
	tank_material.albedo_color = Color(0.98, 0.97, 0.92)
	tank_material.albedo_texture = WHITE_TANK_TEXTURE
	tank_material.uv1_scale = Vector3(3.0, 3.0, 3.0)
	tank_material.roughness = 0.97
	tank_material.metallic = 0.0
	var torso := _find_named_node(hero, "HoodieBody") as MeshInstance3D
	if torso != null:
		torso.material_override = tank_material
	for detail_name in ["Hood", "HoodiePocket", "HoodieZip", "HoodieDrawstrings"]:
		var detail := _find_named_node(hero, detail_name) as MeshInstance3D
		if detail != null:
			detail.visible = false

	# Expose the upper arms instead of retaining long hoodie sleeves and cuffs.
	for side in ["ArmPivot_Left", "ArmPivot_Right"]:
		var arm := _find_named_node(hero, side) as Node3D
		if arm != null:
			for part_name in ["HoodieSleeve", "SleeveCuff"]:
				var clothing_part := arm.get_node_or_null(part_name) as MeshInstance3D
				if clothing_part != null:
					clothing_part.visible = false

	var denim_material := StandardMaterial3D.new()
	denim_material.albedo_color = Color(0.72, 0.82, 0.98)
	denim_material.albedo_texture = BLUE_DENIM_TEXTURE
	denim_material.uv1_scale = Vector3(2.0, 3.0, 2.0)
	denim_material.roughness = 0.96
	denim_material.metallic = 0.0

	var shoe_material := StandardMaterial3D.new()
	shoe_material.albedo_color = Color(0.045, 0.055, 0.072)
	shoe_material.roughness = 0.86
	shoe_material.metallic = 0.0

	for side in ["LegPivot_Left", "LegPivot_Right"]:
		var leg := _find_named_node(hero, side) as Node3D
		if leg == null:
			continue
		var trouser := leg.get_node_or_null("TrouserLeg") as MeshInstance3D
		if trouser != null:
			trouser.material_override = denim_material
		for detail_name in ["CargoPocket", "KneePanel"]:
			var detail := leg.get_node_or_null(detail_name) as MeshInstance3D
			if detail != null:
				detail.visible = false
		for shoe_part_name in ["SneakerSole", "SneakerUpper", "SneakerToeAccent", "SneakerHeelAccent", "SneakerLaces"]:
			var shoe_part := leg.get_node_or_null(shoe_part_name) as MeshInstance3D
			if shoe_part != null:
				shoe_part.material_override = shoe_material


func _add_back_logo() -> void:
	var logo := Label3D.new()
	logo.name = "GhibliBackLogo"
	logo.text = "GTA\nGHIBLI"
	logo.position = Vector3(0.0, 1.14, 0.207)
	logo.font_size = 38
	logo.pixel_size = 0.0034
	logo.modulate = Color(1.0, 0.94, 0.78)
	logo.outline_size = 7
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(logo)


func _build_fallback_character() -> void:
	var shirt := Color(0.96, 0.95, 0.90)
	var pants := Color(0.22, 0.39, 0.68)
	var skin := Color(0.78, 0.56, 0.40)
	var hair := Color(0.055, 0.045, 0.04)
	var dark_shoe := Color(0.045, 0.055, 0.072)

	_add_capsule(self, "WhiteSleevelessShirt", 0.35, 0.92, Vector3(0.0, 1.05, 0.0), shirt)

	_add_sphere(self, "Neck", 0.105, Vector3(0.0, 1.52, 0.0), skin)
	_add_sphere(self, "Head", 0.235, Vector3(0.0, 1.66, -0.01), skin)
	_add_sphere(self, "HairCap", 0.245, Vector3(0.0, 1.78, 0.025), hair,
		Vector3(1.04, 0.70, 1.05))
	_add_sphere(self, "HairBack", 0.19, Vector3(0.0, 1.62, 0.16), hair,
		Vector3(1.0, 0.92, 0.60))
	for index in range(5):
		var x := -0.18 + float(index) * 0.09
		var tuft := SphereMesh.new()
		tuft.radius = 0.095
		tuft.height = 0.19
		_add_mesh(self, "HairTuft_%02d" % index, tuft,
			Vector3(x, 1.91 + float(index % 2) * 0.035, 0.035), hair)

	# Small face details face the character's forward (-Z) direction.
	_add_sphere(self, "Eye_L", 0.022, Vector3(-0.078, 1.68, -0.218), Color(0.08, 0.06, 0.05))
	_add_sphere(self, "Eye_R", 0.022, Vector3(0.078, 1.68, -0.218), Color(0.08, 0.06, 0.05))
	_add_box(self, "Mouth", Vector3(0.065, 0.018, 0.018),
		Vector3(0.0, 1.57, -0.235), Color(0.34, 0.12, 0.10))


	_add_box(self, "TrouserLeftPocket", Vector3(0.20, 0.34, 0.045),
		Vector3(-0.29, 0.42, -0.18), Color(0.18, 0.22, 0.28))
	_add_box(self, "TrouserRightPocket", Vector3(0.20, 0.34, 0.045),
		Vector3(0.29, 0.42, -0.18), Color(0.18, 0.22, 0.28))



	var logo := Label3D.new()
	logo.name = "GhibliBackLogo"
	logo.text = "GTA\nGHIBLI"
	logo.position = Vector3(0.0, 1.13, 0.354)
	logo.font_size = 38
	logo.pixel_size = 0.0034
	logo.modulate = Color(1.0, 0.94, 0.78)
	logo.outline_size = 7
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(logo)

	_add_leg(-1.0, pants, dark_shoe)
	_add_leg(1.0, pants, dark_shoe)
	_add_arm(-1.0, skin)
	_add_arm(1.0, skin)


func _add_leg(side: float, pants_color: Color, shoe_color: Color) -> void:
	var pivot := Node3D.new()
	pivot.name = "LegPivot_Left" if side < 0.0 else "LegPivot_Right"
	pivot.position = Vector3(side * 0.18, 0.70, 0.0)
	add_child(pivot)
	_leg_pivots.append(pivot)
	_add_capsule(pivot, "TrouserLeg", 0.145, 0.76, Vector3(0.0, -0.34, 0.0), pants_color)
	_add_box(pivot, "SneakerSole", Vector3(0.40, 0.07, 0.54),
		Vector3(0.0, -0.61, -0.065), shoe_color)
	_add_box(pivot, "SneakerUpper", Vector3(0.38, 0.17, 0.51),
		Vector3(0.0, -0.51, -0.07), shoe_color)
	_add_box(pivot, "SneakerToeAccent", Vector3(0.25, 0.055, 0.075),
		Vector3(0.0, -0.50, -0.30), shoe_color)
	_add_box(pivot, "SneakerHeelAccent", Vector3(0.16, 0.085, 0.075),
		Vector3(0.0, -0.47, 0.17), shoe_color)

	_add_box(pivot, "SneakerLace_1", Vector3(0.19, 0.018, 0.028),
		Vector3(0.0, -0.46, -0.14), shoe_color.lightened(0.18))
	_add_box(pivot, "SneakerLace_2", Vector3(0.19, 0.018, 0.028),
		Vector3(0.0, -0.43, -0.06), shoe_color.lightened(0.18))
	_add_box(pivot, "SneakerLace_3", Vector3(0.19, 0.018, 0.028),
		Vector3(0.0, -0.40, 0.02), shoe_color.lightened(0.18))



func _add_arm(side: float, skin_color: Color) -> void:
	var pivot := Node3D.new()
	pivot.name = "ArmPivot_Left" if side < 0.0 else "ArmPivot_Right"
	pivot.position = Vector3(side * 0.43, 1.28, 0.0)
	add_child(pivot)
	_arm_pivots.append(pivot)
	_add_capsule(pivot, "BareArm", 0.115, 0.76,
		Vector3(0.0, -0.29, 0.0), skin_color)
	_add_sphere(pivot, "Hand", 0.105, Vector3(0.0, -0.70, -0.015), skin_color)


func _add_capsule(parent: Node3D, node_name: String, radius: float,
		height: float, at: Vector3, color: Color) -> MeshInstance3D:
	var capsule := CapsuleMesh.new()
	capsule.radius = radius
	capsule.height = height
	return _add_mesh(parent, node_name, capsule, at, color)


func _add_sphere(parent: Node3D, node_name: String, radius: float,
		at: Vector3, color: Color, shape_scale: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	var instance := _add_mesh(parent, node_name, sphere, at, color)
	instance.scale = shape_scale
	return instance


func _add_box(parent: Node3D, node_name: String, dimensions: Vector3,
		at: Vector3, color: Color) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = dimensions
	return _add_mesh(parent, node_name, box, at, color)


func _add_mesh(parent: Node3D, node_name: String, mesh_resource: Mesh,
		at: Vector3, color: Color) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh_resource
	instance.position = at
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	if node_name == "WhiteSleevelessShirt":
		material.albedo_color = Color.WHITE
		material.albedo_texture = WHITE_TANK_TEXTURE
		material.uv1_scale = Vector3(2.0, 2.0, 2.0)
		material.roughness = 0.97
	elif node_name.begins_with("Trouser"):
		material.albedo_color = Color(0.72, 0.82, 0.98)
		material.albedo_texture = BLUE_DENIM_TEXTURE
		material.uv1_scale = Vector3(2.0, 3.0, 2.0)
		material.roughness = 0.96
	instance.material_override = material
	parent.add_child(instance)
	return instance
