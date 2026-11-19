extends SceneTree

const REGIONS_SCRIPT = preload("res://scripts/world/open_world_regions.gd")

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var regions := Node3D.new()
	regions.set_script(REGIONS_SCRIPT)
	root.add_child(regions)
	await process_frame
	var harbor := regions.get_node_or_null("HarborCity") as Node3D
	if harbor == null:
		_fail("Harbor City was not created.")
		return
	var crane := harbor.get_node_or_null("HarborGantryCrane") as StaticBody3D
	if crane == null:
		_fail("The original gantry crane is not attached to the live Harbor City district.")
		return
	var frame := crane.get_node_or_null("CraneFrame") as MeshInstance3D
	if frame == null or frame.mesh == null or frame.mesh.get_surface_count() < 4:
		_fail("The imported gantry crane mesh or its material surfaces are missing.")
		return
	var area := crane.get_node_or_null("InteractionArea") as Area3D
	if area == null or not area.is_in_group("interaction_areas"):
		_fail("The crane control point is not registered with the shared interaction system.")
		return
	var hoist := crane.call("get_hoist_node") as Node3D
	if hoist == null:
		_fail("The moving cargo hoist was not created.")
		return
	var initial_height := float(crane.call("get_lift_height"))
	crane.call("interact")
	for _frame_index in range(100):
		await process_frame
	var raised_height := float(crane.call("get_lift_height"))
	if raised_height <= initial_height + 0.45 or not is_equal_approx(hoist.position.y, raised_height):
		_fail("The crane did not raise its suspended cargo when interacted with.")
		return
	crane.call("interact")
	for _frame_index in range(100):
		await process_frame
	var lowered_height := float(crane.call("get_lift_height"))
	if lowered_height >= raised_height - 0.45 or not is_equal_approx(hoist.position.y, lowered_height):
		_fail("The crane did not lower its suspended cargo on the second interaction.")
		return
	print("PASS: Harbor City gantry crane mesh, interaction registration, cargo lift and lower cycle.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
