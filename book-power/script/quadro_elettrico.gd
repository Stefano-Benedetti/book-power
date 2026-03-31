extends StaticBody2D


var player_in_area = false
var player = null
@export var attivo: bool = false
@export var activation_key: InvItem


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if attivo:
		return
	if player_in_area:
		if Input.is_action_just_pressed("Pick_object") and player.selected_item==activation_key:
			Global.quadro_attivato.emit()
			attivo = true
			print("quadro elettrico attivato")


func _on_area_of_interaction_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true
		player = body

func _on_area_of_interaction_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
