extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.removeFireWall.connect(removeFireWall)
	if QuestCounter.quest_corrente==8:
		removeFireWall()
	
func removeFireWall():
	var tmp := get_node_or_null("TileMap/temporary_objects")
	if tmp:
		tmp.queue_free()
