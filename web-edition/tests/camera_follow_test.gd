extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/camera_follow.gd").new()
	assert(m.configure(8.0,Vector3(0,4,7)))
	var p=m.next_position(Vector3.ZERO,Vector3(10,0,0),0.1)
	assert(p.x>0.0 and p.x<10.0)
	assert(m.next_position(p,Vector3.ZERO,0.0)==p)
	assert(m.look_target(Vector3.ZERO).y==1.5)
	print("PASS: Third-Person Camera Follow.")
	quit(0)
