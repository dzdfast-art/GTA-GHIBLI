extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	extends RefCounted
	class_name GhibliPolicePursuit
	var state: String="idle"
	var target: Vector3=Vector3.ZERO
	var search_time: float=0.0
	func start(player_position: Vector3) -> void:
		target=player_position
		state="pursuing"
		search_time=0.0
	func update_sighting(player_position: Vector3, visible: bool, delta: float) -> String:
		if state=="idle": return state
		if visible:
			target=player_position
			state="pursuing"
			search_time=0.0
		else:
			state="searching"
			search_time+=maxf(0.0,delta)
			if search_time>=20.0: state="lost"
		return state
	func reset() -> void:
		state="idle"
		search_time=0.0
	print("PASS: Police Pursuit State.")
	quit(0)
