extends Node

var quest_corrente = 0


func _ready() -> void:
	pass # Replace with function body.

func to_next_quest():
	quest_corrente += 1

func get_counter():
	return quest_corrente
