extends RefCounted
class_name GhibliPauseMenuState
const ITEMS=["RESUME","START NEW GAME","MAP","STATS","BRIEF","OPTIONS","QUIT GAME"]
var selected_index: int=0
func move_selection(direction: int) -> int:
	if direction==0: return selected_index
	selected_index=(selected_index+signi(direction)+ITEMS.size())%ITEMS.size()
	return selected_index
func get_selected_item() -> String:
	return ITEMS[selected_index]
func select(index: int) -> bool:
	if index<0 or index>=ITEMS.size(): return false
	selected_index=index
	return true
func get_items() -> Array:
	return ITEMS.duplicate()