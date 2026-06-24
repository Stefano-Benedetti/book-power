extends Node2D

var player_in_area = false
var player = null
@export var key_dropped: bool = false
@export var activation_key: InvItem

signal drop_key

func _ready():
	$button_icon.hide()

func _process(_delta: float) -> void:
	if key_dropped:
		return
	if player_in_area:
		if player.selected_item==activation_key:
			if not $button_icon.visible:
				mostra_button()
				Global.pickIncrement()
			if Input.is_action_just_pressed("Pick_object"):
				drop_key.emit()
		if player.selected_item!=activation_key and $button_icon.visible:
			Global.pickDecrement()
			$button_icon.hide()


func _on_place_router_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true
		player = body


func _on_place_router_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
		if $button_icon.visible:
			Global.pickDecrement()
			$button_icon.hide()


func mostra_button():
	$button_icon.show()
	while player_in_area and not key_dropped:
		if player.selected_item!=activation_key:
			$button_icon.hide()
			break
		$button_icon.modulate.a = 1
		await get_tree().create_timer(0.7).timeout
		$button_icon.modulate.a = 0.5
		await get_tree().create_timer(0.5).timeout
	$button_icon.hide()
