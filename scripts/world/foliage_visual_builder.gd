extends RefCounted

## Builds a layered, textured low-poly tree silhouette for the mobile village.
## All meshes are shared in shape and use compact SVG textures instead of large
## high-resolution scans, keeping the improvement useful for Android budgets.

const FOLIAGE_TEXTURE: Texture2D = preload("res://assets/environment/materials/willow_foliage_detail.svg")
const BARK_TEXTURE: Texture2D = preload("res://assets/environment/materials/willow_bark_detail.svg")

static func build_tree_geometry(tree: Node3D, scale_factor: float = 1.0, variant: int = 0) -> void:
	var bark := StandardMaterial3D.new()
	bark.albedo_color = Color(0.78, 0.76, 0.68)
	bark.albedo_texture = BARK_TEXTURE
	bark.uv1_scale = Vector3(1.0, 2.2, 1.0)
	bark.roughness = 0.96

	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.22
	trunk_mesh.bottom_radius = 0.38
	trunk_mesh.height = 2.85
	trunk_mesh.radial_segments = 10
	var trunk := MeshInstance3D.new()
	trunk.name = "TexturedTrunk"
	trunk.mesh = trunk_mesh
	trunk.position = Vector3(0.0, 1.425, 0.0)
	trunk.material_override = bark
	tree.add_child(trunk)

	_add_branch(tree, "Branch_Left", Vector3(-0.22, 2.15, 0.0), Vector3(0.0, 0.0, 34.0), bark)
	_add_branch(tree, "Branch_Right", Vector3(0.22, 2.22, 0.0), Vector3(0.0, 0.0, -34.0), bark)
	_add_branch(tree, "Branch_Front", Vector3(0.0, 2.35, 0.10), Vector3(34.0, 0.0, 0.0), bark)
	_add_branch(tree, "Branch_Back", Vector3(0.0, 2.30, -0.10), Vector3(-32.0, 0.0, 0.0), bark)

	var offsets: Array[Vector3] = [
		Vector3(0.0, 3.55, 0.0),
		Vector3(-0.86, 3.35, 0.08),
		Vector3(0.86, 3.38, 0.02),
		Vector3(0.0, 3.27, 0.82),
		Vector3(0.0, 3.30, -0.78),
		Vector3(-0.48, 4.05, -0.12),
		Vector3(0.48, 4.02, 0.06),
		Vector3(-0.62, 2.85, 0.42),
		Vector3(0.64, 2.88, 0.36)
	]
	var cluster_scales: Array[Vector3] = [
		Vector3(1.12, 1.12, 1.0),
		Vector3(0.92, 0.96, 0.92),
		Vector3(0.94, 0.98, 0.94),
		Vector3(0.86, 0.90, 0.88),
		Vector3(0.86, 0.90, 0.88),
		Vector3(0.78, 0.84, 0.82),
		Vector3(0.80, 0.84, 0.82),
		Vector3(0.72, 0.78, 0.76),
		Vector3(0.73, 0.78, 0.76)
	]
	var tones: Array[Color] = [
		Color(0.83, 0.98, 0.72),
		Color(0.72, 0.91, 0.60),
		Color(0.68, 0.88, 0.57),
		Color(0.78, 0.94, 0.63),
		Color(0.58, 0.80, 0.49),
		Color(0.86, 0.97, 0.68),
		Color(0.69, 0.89, 0.55),
		Color(0.55, 0.77, 0.44),
		Color(0.62, 0.83, 0.48)
	]

	for index in range(offsets.size()):
		var leaf_mesh := SphereMesh.new()
		leaf_mesh.radius = 0.88
		leaf_mesh.height = 1.58
		leaf_mesh.radial_segments = 12
		leaf_mesh.rings = 7
		var leaf_material := StandardMaterial3D.new()
		leaf_material.albedo_color = tones[(index + variant) % tones.size()]
		leaf_material.albedo_texture = FOLIAGE_TEXTURE
		leaf_material.uv1_scale = Vector3(1.7, 1.7, 1.7)
		leaf_material.roughness = 0.98
		var cluster := MeshInstance3D.new()
		cluster.name = "FoliageCluster_%02d" % index
		cluster.mesh = leaf_mesh
		cluster.position = offsets[index]
		cluster.scale = cluster_scales[index]
		cluster.material_override = leaf_material
		tree.add_child(cluster)


static func _add_branch(parent: Node3D, node_name: String, branch_position: Vector3,
		branch_rotation: Vector3, material: StandardMaterial3D) -> void:
	var branch_mesh := CylinderMesh.new()
	branch_mesh.top_radius = 0.055
	branch_mesh.bottom_radius = 0.13
	branch_mesh.height = 1.25
	branch_mesh.radial_segments = 7
	var branch := MeshInstance3D.new()
	branch.name = node_name
	branch.mesh = branch_mesh
	branch.position = branch_position
	branch.rotation_degrees = branch_rotation
	branch.material_override = material
	parent.add_child(branch)
