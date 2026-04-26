extends Node2D

@onready var firewall = $TileMap/temporary_objects

var parlato = false

var player_in_talkArea = false

func _ready() -> void:
	Global.removeFireWall.connect(removeFireWall)
	removeFireWall()
	
func _process(delta: float) -> void:
	if player_in_talkArea and Input.is_action_just_pressed("Pick_object"):
			Global.emit_signal("start_dialog")
	
func removeFireWall():
	if firewall.visible:
		firewall.collision_enabled = false
		firewall.hide()

func placeFireWall():
	if not firewall.visible:
		firewall.collision_enabled = true
		firewall.show()


func _on_area_dialogo_body_entered(body: Node2D) -> void:
	if !parlato and body.has_method("player"):
		parlato = true
		player_in_talkArea = true
		placeFireWall()
		Global.emit_signal("start_dialog")
