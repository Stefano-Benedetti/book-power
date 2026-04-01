extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.removeRoadblock.connect(removeRoadblock)
	if QuestCounter.quest_corrente==1:
		removeRoadblock()
	
func removeRoadblock():
	var tmp := get_node_or_null("TileMap/temporary_objects")
	if tmp:
		tmp.queue_free()
