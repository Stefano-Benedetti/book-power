extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.removeRoadblock.connect(removeRoadblock)
	if QuestCounter.quest_corrente==1:
		removeRoadblock()
	
func removeRoadblock():
	remove_child($TileMap/temporary_objects)
