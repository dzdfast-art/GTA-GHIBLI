extends RefCounted
class_name GhibliIntegrationHealth
var checks: Dictionary={}
func record_check(name: String, passed: bool, detail: String="") -> bool:
	if name.is_empty(): return false
	checks[name]={"passed":passed,"detail":detail}
	return true
func is_healthy() -> bool:
	if checks.is_empty(): return false
	for check in checks.values():
		if not check.passed: return false
	return true
func get_report() -> Dictionary:
	return {"total":checks.size(),"passed":_passed_count(),"healthy":is_healthy(),"checks":checks.duplicate(true)}
func _passed_count() -> int:
	var count=0
	for c in checks.values():
		if c.passed: count+=1
	return count