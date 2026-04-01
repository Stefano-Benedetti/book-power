extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.fixElSys.connect(circuiti_attivati)
	QuestCounter.quest_corrente = 2

func circuiti_attivati():
	QuestCounter.quest_corrente = 3


func _on_to_next_level_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		print("NUOVO LIVELLO EVVIVAA!!!")
		#get_tree().call_deferred("change_scene_to_file", "res://levels/scenes/livello_2.tscn")
