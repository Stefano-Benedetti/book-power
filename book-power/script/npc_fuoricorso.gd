extends CharacterBody2D

signal start_dialog

var player_in_area = false
var player = null

func _ready():
	play_anim()
	
func _process(_delta: float) -> void:
	if player_in_area:
		if Input.is_action_just_pressed("Pick_object"):
			Global.emit_signal("start_dialog")

func play_anim():
	var anim = $AnimatedSprite2D
	anim.play("front_idle")


func _on_talk_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true
		player = body


func _on_talk_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
