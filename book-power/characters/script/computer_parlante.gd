extends CharacterBody2D

@export var dropped_object: PackedScene
var offset_drop = Vector2(0, 20)
var dropped = false

var player_in_area = false
var player = null

func _ready():
	play_anim()
	Global.fine_dialogo_computer.connect(play_anim)
	
func _process(_delta: float) -> void:
	if player_in_area:
		if Input.is_action_just_pressed("Pick_object"):
			if not GameState.in_dialogue:
				var anim = $AnimatedSprite2D
				anim.play("talking")
			Global.emit_signal("start_computer_dialog")

func play_anim():
	var anim = $AnimatedSprite2D
	anim.play("idle")


func _on_talk_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true
		player = body


func _on_talk_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false

func dropObject():
	if dropped_object == null or dropped:
		return
	var scena_dropped_object = dropped_object.instantiate()
	get_parent().add_child(scena_dropped_object)
	scena_dropped_object.global_position = global_position + offset_drop
	dropped = true
