extends SceneTree
const SCENE = preload("res://scenes/world/coastal_lighthouse.tscn")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var lighthouse := SCENE.instantiate()
	root.add_child(lighthouse)
	await process_frame
	var visual := lighthouse.get_node_or_null("LighthouseMesh") as MeshInstance3D
	if visual == null or visual.mesh == null or visual.mesh.get_surface_count() < 7:
		_fail("The lighthouse must import seven material surfaces.")
		return
	var body := lighthouse.get_node_or_null("LighthouseCollision") as StaticBody3D
	var area := lighthouse.get_node_or_null("InteractionArea") as Area3D
	if body == null or body.get_child_count() == 0 or area == null:
		_fail("Tower collision and shared proximity interaction are required.")
		return
	var beam := lighthouse.get_node_or_null("BeaconSweep/RotatingBeam") as SpotLight3D
	if beam == null or beam.shadow_enabled:
		_fail("The rotating beam must exist without real-time shadows.")
		return
	lighthouse.call("set_day_phase", "day")
	if lighthouse.call("is_beacon_active") or beam.visible:
		_fail("The beacon must be off during the day.")
		return
	lighthouse.call("set_day_phase", "dusk")
	if not lighthouse.call("is_beacon_active") or not beam.visible:
		_fail("The beacon must activate at dusk.")
		return
	var sweep := lighthouse.get_node("BeaconSweep") as Node3D
	var angle_before := sweep.rotation.y
	lighthouse.call("_process", 1.0)
	if is_equal_approx(angle_before, sweep.rotation.y):
		_fail("The active beacon must rotate.")
		return
	lighthouse.call("set_day_phase", "night")
	if not lighthouse.call("is_beacon_active"):
		_fail("The beacon must remain active at night.")
		return
	lighthouse.call("set_day_phase", "day")
	if lighthouse.call("is_beacon_active"):
		_fail("The beacon must switch off again at sunrise.")
		return
	lighthouse.set("_player_nearby", true)
	if not lighthouse.call("interact"):
		_fail("Nearby players must be able to inspect the lighthouse.")
		return
	var feedback := lighthouse.get_node("LandmarkFeedback") as Label3D
	if not feedback.visible or not feedback.text.contains("منارة ساحل الياقوت"):
		_fail("Interaction feedback must be localized in Arabic.")
		return
	print("PASS: Lighthouse import, collision, interaction, day/night toggle and rotating beacon.")
	quit(0)
func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
