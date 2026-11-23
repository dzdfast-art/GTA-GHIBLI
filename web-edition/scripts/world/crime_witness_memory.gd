extends RefCounted
class_name GhibliCrimeWitnessMemory
var witnesses: Dictionary={}
func record(witness_id: String, crime_id: String, position: Vector3, confidence: float) -> bool:
	if witness_id.is_empty() or crime_id.is_empty() or confidence<0.0 or confidence>1.0: return false
	if not witnesses.has(crime_id): witnesses[crime_id]=[]
	witnesses[crime_id].append({"witness":witness_id,"position":position,"confidence":confidence})
	return true
func get_witness_count(crime_id: String) -> int:
	return witnesses.get(crime_id,[]).size()
func get_best_confidence(crime_id: String) -> float:
	var best=0.0
	for w in witnesses.get(crime_id,[]): best=maxf(best,float(w.confidence))
	return best