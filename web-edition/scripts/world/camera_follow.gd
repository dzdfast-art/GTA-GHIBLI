extends RefCounted
class_name GhibliCameraFollow
var smoothing: float=8.0
var offset: Vector3=Vector3(0,4,7)
func configure(rate: float, camera_offset: Vector3) -> bool:
	if rate<=0.0: return false
	smoothing=rate
	offset=camera_offset
	return true
func next_position(current: Vector3, target: Vector3, delta: float) -> Vector3:
	if delta<=0.0: return current
	return current.lerp(target+offset,1.0-exp(-smoothing*delta))
func look_target(target: Vector3, height: float=1.5) -> Vector3:
	return target+Vector3.UP*height