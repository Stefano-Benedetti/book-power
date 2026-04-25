extends Node2D

func _ready() -> void:
	removeFireWall()
	Global.placeFireWall.connect(placeFireWall)
	
func removeFireWall():
	var tmp := get_node_or_null("TileMap/temporary_objects")
	if tmp.visible:
		tmp.collision_enabled = false
		tmp.hide()

func placeFireWall():
	var tmp := get_node_or_null("TileMap/temporary_objects")
	if not tmp.visible:
		tmp.collision_enabled = true
		tmp.show()


func _on_area_dialogo_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		placeFireWall()
