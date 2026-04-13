extends CharacterBody2D

@export var object_posseduto: PackedScene

@export var damage = 5
@export var attack_mode = true
@onready var attack_cooldown = $attackCooldown
var player_in_attackArea = false
var can_attack = true

@onready var move_cooldown = $movementPostAttackCooldown
var can_move = true
var SPEED = 100

var player = null

var player_in_talkArea = false
var offset_drop = Vector2(-20,0)

var dialogo_iniziato = false

var can_talk = true

var exiting = false

func _ready():
	Global.sbloccaRobot.connect(sblocca)
	Global.muovi_robot.connect(exit)
	Global.fine_dialogo_robot.connect(dropObject)

func exit():
	get_tree().create_timer(3).timeout.connect(func(): queue_free())
	exiting = true

func goOutOfView():
	$AnimatedSprite2D.play("right_walk")
	velocity.x = SPEED
	velocity.y = 0
	move_and_slide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if exiting:
		goOutOfView()
	elif attack_mode and player_in_attackArea and can_attack:
		robot_attack()
	elif can_move:
		$AnimatedSprite2D.play("left_idle")
		if player_in_talkArea and can_talk and Input.is_action_just_pressed("Pick_object"):
			Global.emit_signal("start_robot_dialog")

func dropObject():
	if object_posseduto == null:
		return
	var scena_dropped_object = object_posseduto.instantiate()
	get_parent().add_child(scena_dropped_object)
	scena_dropped_object.global_position = global_position + offset_drop
	object_posseduto = null
	can_talk = false


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
	if not can_talk:
		return
	if body.has_method("player"):
		player_in_talkArea = true
		player = body
		if not attack_mode:
			Global.emit_signal("start_robot_dialog")
			dialogo_iniziato = true

func _on_talk_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_talkArea = false
	if body.has_method("libro_asd"):
		await get_tree().create_timer(1).timeout
		can_talk = true
