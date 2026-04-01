extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.removeRoadblock.connect(removeRoadblock)
	if QuestCounter.quest_corrente==1:
		removeRoadblock()
	
func removeRoadblock():
	if $TileMap/temporary_objects:
		$TileMap/temporary_objects.queue_free()
