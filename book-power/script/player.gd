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


func _physics_process(delta: float):
	player_movement(delta)
	
func player_movement(delta):
	if Input.is_action_pressed("muovi_a_destra"):
		current_dir = "right"
		play_anim(1)
		velocity.x = SPEED
		velocity.y = 0
	elif Input.is_action_pressed("muovi_a_sinistra"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -SPEED
		velocity.y = 0
	elif Input.is_action_pressed("muovi_su"):
		current_dir = "up"
		play_anim(1)
		velocity.x = 0
		velocity.y = -SPEED
	elif Input.is_action_pressed("muovi_giù"):
		current_dir = "down"
		play_anim(1)
		velocity.x = 0
		velocity.y = SPEED
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide()


#funzione per gestire le animazioni del player, movement=1 => ci stiamo muovendo
func play_anim(movement):
	var anim = $AnimatedSprite2D
	if current_dir == "right":
		if movement==1:
			anim.play("right_walk")
		elif movement==0:
			anim.play("right_idle")
	if current_dir == "left":
		if movement==1:
			anim.play("left_walk")
		elif movement==0:
			anim.play("left_idle")
	if current_dir == "up":
		if movement==1:
			anim.play("rear_walk")
		elif movement==0:
			anim.play("rear_idle")
	if current_dir == "down":
		if movement==1:
			anim.play("front_walk")
		elif movement==0:
			anim.play("front_idle")


#funzione per prendere oggetti, è chiamata dall'oggetto che viene preso
func collect(item):
	var inserimento_riuscito = inv.insert(item)		#lo possiamo fare perchè abbiamo fatto sopra nel codice l'export di inv
	return inserimento_riuscito

func getHurt():
	current_health -= 10
	health_changed.emit()
