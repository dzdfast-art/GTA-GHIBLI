extends RefCounted
class_name GhibliDialogueBranching
var nodes: Dictionary={}
func add_node(id: String, text: String, choices: Array[String]) -> bool:
	if id.is_empty() or text.is_empty() or nodes.has(id): return false
	nodes[id]={"text":text,"choices":choices.duplicate()}
	return true
func get_node(id: String) -> Dictionary:
	return nodes.get(id,{}).duplicate(true)
func choose(id: String, choice_index: int) -> String:
	if not nodes.has(id): return ""
	var choices: Array=nodes[id].choices
	if choice_index<0 or choice_index>=choices.size(): return ""
	return str(choices[choice_index])
func has_node(id: String) -> bool:
	return nodes.has(id)