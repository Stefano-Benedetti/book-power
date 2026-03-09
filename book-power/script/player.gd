extends CharacterBody2D

class_name Player
#serve a altri nodi per identificare chi è entrato attraverso il "has_method()"
func player():
	pass


const SPEED = 50
var current_dir = "down"		#la inizializziamo giù

@export var max_health = 100
@onready var current_health: int = max_health
signal health_changed	#questo serve per aggiornare la health bar

@export var inv: Inv	#con questo possiamo richiamare le funzioni dell'inventario del player
@export var selected_item: InvItem 

var can_attack = true
var can_move = true
@onready var attacck_cooldown: Timer=$attackCooldown
@onready var mov_cooldown: Timer=$movementPostAttackCooldown
@onready var attacco_libro_analisi = preload("res://scenes/attacco_libro_analisi.tscn")

func _ready():
	Global.selected_slot_update.connect(updateSelectedItem)

func _physics_process(delta: float):
	if Input.is_action_pressed("attacca") and can_attack:
		attacca()
	elif can_move:
		player_movement(delta)

func player_movement(delta):
	if Input.is_action_pressed("muovi_a_destra"):
		current_dir = "right"
		play_anim(1, 0)
		velocity.x = SPEED
		velocity.y = 0
	elif Input.is_action_pressed("muovi_a_sinistra"):
		current_dir = "left"
		play_anim(1, 0)
		velocity.x = -SPEED
		velocity.y = 0
	elif Input.is_action_pressed("muovi_su"):
		current_dir = "up"
		play_anim(1, 0)
		velocity.x = 0
		velocity.y = -SPEED
	elif Input.is_action_pressed("muovi_giù"):
		current_dir = "down"
		play_anim(1, 0)
		velocity.x = 0
		velocity.y = SPEED
	else:
		play_anim(0, 0)
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide()

func attacca():
	if selected_item == null:
		return
	elif selected_item.name == "libro_analisi":
		var scena_attacco_analisi = attacco_libro_analisi.instantiate()
		scena_attacco_analisi.global_position = global_position
		match current_dir:
			"right":
				scena_attacco_analisi.rotation_degrees = 0
			"left":
				scena_attacco_analisi.rotation_degrees = 180
			"up":
				scena_attacco_analisi.rotation_degrees = -90
			"down":
				scena_attacco_analisi.rotation_degrees = 90
		get_tree().current_scene.add_child(scena_attacco_analisi)
		
		can_attack = false
		can_move = false
		attacck_cooldown.start()  # Avvia il timer
		mov_cooldown.start()
		play_anim(0, 1)


#funzione per gestire le animazioni del player, movement=1 => ci stiamo muovendo
func play_anim(movement, attaccando):
	var anim = $AnimatedSprite2D
	if current_dir == "right":
		if movement==1:
			anim.play("right_walk")
		elif movement==0:
			if attaccando:
				anim.play("right_attack_spell")
			else:
				anim.play("right_idle")
	if current_dir == "left":
		if movement==1:
			anim.play("left_walk")
		elif movement==0:
			if attaccando:
				anim.play("left_attack_spell")
			else:
				anim.play("left_idle")
	if current_dir == "up":
		if movement==1:
			anim.play("rear_walk")
		elif movement==0:
			if attaccando:
				anim.play("rear_attack_spell")
			else:
				anim.play("rear_idle")
	if current_dir == "down":
		if movement==1:
			anim.play("front_walk")
		elif movement==0:
			if attaccando:
				anim.play("front_attack_spell")
			else:
				anim.play("front_idle")


#funzione per prendere oggetti, è chiamata dall'oggetto che viene preso
func collect(item):
	var inserimento_riuscito = inv.insert(item)		#lo possiamo fare perchè abbiamo fatto sopra nel codice l'export di inv
	return inserimento_riuscito

func updateSelectedItem(slot: InvSlot):
	selected_item = slot.item

func getHurt():
	current_health -= 10
	health_changed.emit()	#per aggiornare la health bar


func _on_attack_cooldown_timeout() -> void:
	can_attack = true

func _on_movement_post_attack_cooldown_timeout() -> void:
	can_move = true
