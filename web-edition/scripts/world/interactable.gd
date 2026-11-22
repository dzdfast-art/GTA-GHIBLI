extends Node3D
class_name GhibliInteractable

signal activated(action_id: String)

@export var action_id: String = ""
@export var display_name: String = ""
@export var interaction_text: String = "E — Interact"


func _ready() -> void:
	add_to_group("interactables")


func activate() -> void:
	if not action_id.is_empty():
		activated.emit(action_id)
