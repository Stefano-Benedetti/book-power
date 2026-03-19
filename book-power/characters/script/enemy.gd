extends CharacterBody2D

class_name Enemy
#serve a altri nodi per identificare chi è entrato attraverso il "has_method()"
func enemy():
	pass

const SPEED = 30
var current_dir = "down"		#la inizializziamo giù

@export var dropped_object: PackedScene
var offset_drop = Vector2(0, -3)

@export var max_health = 10
@onready var current_health: int = max_health
@onready var health_bar: TextureProgressBar=$enemy_health_bar
var dead = false

#variabili per collegarsi al player
var player_in_area = false
var player = null

var player_attackable = false
var can_attack = true
var can_move = true
@onready var attacck_cooldown: Timer=$attackCooldown
@onready var mov_cooldown: Timer=$movementPostAttackCooldown
@onready var nuvoletta: Control=$enemy_cloud

@onready var nav_agent = $NavigationAgent2D  # Collegamento al nodo NavigationAgent2D

var spawn_point = null

var default_nav_timer = randf()
var nav_timer

func _ready():
	spawn_point = global_position
	nuvoletta.visible = false
	resetNavTimer()

func _physics_process(delta: float):
	nav_timer -= delta
	manage_enemy(delta)
	if nav_timer<0:
		resetNavTimer()


func manage_enemy(delta):
	if dead:
		return
	elif current_health<=0:
		die()
	elif player_attackable and can_attack:
		enemy_attack()
	elif can_move:
		enemy_movement(delta)



#quando il timer finisce imposta can_attack a true
func _on_attack_cooldown_timeout():
	can_attack = true

func _on_movement_post_attack_cooldown_timeout() -> void:
	can_move = true
	nuvoletta.visible = false

func enemy_attack():
	can_attack = false
	can_move = false
	player.getHurt()
	attacck_cooldown.start()  # Avvia il timer
	mov_cooldown.start()
	
	nuvoletta.randomText()
	nuvoletta.visible = true
	
	play_anim(0, 1)


#non basta che una delle due direzioni sia maggiore dell'altra
#deve essere proprio dominante (> di almento 0,5) in questo
#modo comunque non esce dal percorso, perchè quando si avvicina
#molto a un ostacolo (area non camminabile) la direzione dominan.
#sarà quella che gli farà cambiare la direzione.
#NOTA: finchè non cambia la direzione dominan. lui cammina sempre
#nella stessa direzione
func enemy_movement(delta):
	if nav_timer>=0:
		move_and_slide()
		return
	if abs(position.x-spawn_point.x) < 20 and abs(position.y-spawn_point.y)<20 and !player_in_area:
		play_anim(0, 0)
		velocity.x = 0
		velocity.y = 0
		return
	elif player_in_area:
		nav_agent.target_position = player.global_position	# Imposta la posizione target al player
	else:
		nav_agent.target_position = spawn_point
		
	# Ottieni il prossimo waypoint dal percorso calcolato
	if not nav_agent.is_navigation_finished():
		var next_pos = nav_agent.get_next_path_position()
		var direction = (next_pos - global_position).normalized()
		if abs(abs(direction.x)-abs(direction.y))>0.5:
			if abs(direction.x)>0.5:
				if direction.x > 0:
					current_dir = "right"
					velocity.x = SPEED
					velocity.y = 0
				else:
					current_dir = "left"
					velocity.x = -SPEED
					velocity.y = 0
			else:
				if direction.y > 0:
					current_dir = "down"
					velocity.x = 0
					velocity.y = SPEED
				else:
					current_dir = "up"
					velocity.x = 0
					velocity.y = -SPEED
		play_anim(1, 0)
	move_and_slide()

func resetNavTimer():
	nav_timer = default_nav_timer


#funzione per gestire le animazioni del player, movement=1 => ci stiamo muovendo
func play_anim(movement, attaccando):
	var anim = $AnimatedSprite2D
	if current_dir == "right":
		if movement==1:
			anim.play("right_walk")
		elif movement==0:
			if attaccando==0:
				anim.play("right_idle")
			else:
				anim.play("right_attack")
	if current_dir == "left":
		if movement==1:
			anim.play("left_walk")
		elif movement==0:
			if attaccando==0:
				anim.play("left_idle")
			else:
				anim.play("left_attack")
	if current_dir == "up":
		if movement==1:
			anim.play("rear_walk")
		elif movement==0:
			if attaccando==0:
				anim.play("rear_idle")
			else:
				anim.play("rear_attack")
	if current_dir == "down":
		if movement==1:
			anim.play("front_walk")
		elif movement==0:
			if attaccando==0:
				anim.play("front_idle")
			else:
				anim.play("front_attack")




#setta le variabili collegate al player quando questo entra nella player_detection_area
func _on_player_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true
		player = body

func _on_player_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false


#setta la variabile che dice se il player è attaccabile o no
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_attackable = true
		player = body

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_attackable = false


func getHurt(damage):
	current_health -= damage
	health_bar.update()


func dropObject():
	if dropped_object == null:
		return
	var scena_dropped_object = dropped_object.instantiate()
	get_parent().add_child(scena_dropped_object)
	scena_dropped_object.global_position = global_position + offset_drop


func die():
	dead = true
	var anim = $AnimatedSprite2D
	anim.play("die")
	await get_tree().create_timer(2.0).timeout #crea un timer di due secondi e aspetta la fine
	dropObject()
	queue_free()
