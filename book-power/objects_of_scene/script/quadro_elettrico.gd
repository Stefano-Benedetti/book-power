extends StaticBody2D


var player_in_area = false
var player = null
@export var attivo: bool = false
@export var activation_key: InvItem

var button_visible = false

func _ready():
	$button_icon.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if attivo:
		return
	if player_in_area:
		if player.selected_item==activation_key and not button_visible:
			mostra_button()
		if Input.is_action_just_pressed("attacca") and player.selected_item==activation_key:
			Global.quadro_attivato.emit()
			attivo = true
			$AnimatedSprite2D.play()
			Global.emit_signal("fixElSys")
			$button_icon.hide()


func _on_area_of_interaction_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true
		player = body


func _on_area_of_interaction_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
		$button_icon.hide()
		button_visible = false


func mostra_button():
	button_visible = true
	$button_icon.show()
	while player_in_area and not attivo:
		if player.selected_item!=activation_key:
			button_visible = false
			$button_icon.hide()
			break
		$button_icon.modulate.a = 1
		await get_tree().create_timer(0.7).timeout
		$button_icon.modulate.a = 0.5
		await get_tree().create_timer(0.5).timeout
