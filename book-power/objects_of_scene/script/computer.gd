extends Node2D


@export var chiave: InvItem

var player_in_area = false
var player = null

var used = false
var offset_drop = Vector2(0, 10)

func _ready() -> void:
	
	if get_parent().name == "mappa03":
		$AnimatedSprite2D.animation = "turn_red_screen"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if used or not player_in_area or not player.selected_item==chiave:
		return
	if Input.is_action_just_pressed("attacca"):
		Global.sbloccaRobot.emit()
		$AnimatedSprite2D.animation = "turn_green_screen"



func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true
		player = body

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
