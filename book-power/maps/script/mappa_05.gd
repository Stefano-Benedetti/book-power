extends Node2D

@onready var firewall = $TileMap/temporary_objects

func _ready() -> void:
	removeFireWall()
	Global.placeFireWall.connect(placeFireWall)
	
func removeFireWall():
	if firewall.visible:
		firewall.collision_enabled = false
		firewall.hide()

func placeFireWall():
	if not firewall.visible:
		firewall.collision_enabled = true
		firewall.show()


func _on_area_dialogo_body_entered(body: Node2D) -> void:
	if body.has_method("player"):	#opportuno verificare anche che non stai già combattendo
		placeFireWall()
