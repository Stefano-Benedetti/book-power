extends CharacterBody2D

@export var object_posseduto: PackedScene
@export var chiave: InvItem

@export var damage = 5
@export var attack_mode = true
@onready var attack_cooldown = $attackCooldown
var player_in_attackArea = false
var can_attack = true

@onready var move_cooldown = $movementPostAttackCooldown
var can_move = true

var player = null

var player_in_talkArea = false
var offset_drop = Vector2(0, 10)

var parlato = false

func _ready():
	Global.sbloccaRobot.connect(sblocca)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if attack_mode and player_in_attackArea and can_attack:
		robot_attack()
	elif can_move:
		$AnimatedSprite2D.play("left_idle")
		if player_in_talkArea and not attack_mode and Input.is_action_just_pressed("Pick_object"):
			Global.emit_signal("start_robot_dialog")



func dropObject():
	if object_posseduto == null:
		return
	var scena_dropped_object = object_posseduto.instantiate()
	get_parent().add_child(scena_dropped_object)
	scena_dropped_object.global_position = global_position + offset_drop


func robot_attack():
	can_attack = false
	can_move = false
	player.getHurt(damage)
	player.setPushed(Vector2(-1,0), 300, 0.9, 2)
	attack_cooldown.start()  # Avvia il timer
	move_cooldown.start()  # Avvia il timer
	
	$AnimatedSprite2D.play("left_attack")
	await $AnimatedSprite2D.animation_finished


func sblocca():
	attack_mode = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_attackArea = true
		player = body

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_attackArea = false


func _on_attack_cooldown_timeout() -> void:
	can_attack = true

func _on_movement_post_attack_cooldown_timeout() -> void:
	can_move = true


func _on_talk_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_talkArea = true
		player = body
		if not attack_mode and not parlato:
			Global.emit_signal("start_robot_dialog")
			parlato = true

func _on_talk_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_talkArea = false
