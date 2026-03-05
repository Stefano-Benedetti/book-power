extends CharacterBody2D

class_name Enemy
#serve a altri nodi per identificare chi è entrato attraverso il "has_method()"
func enemy():
	pass

const SPEED = 30
var current_dir = "down"		#la inizializziamo giù

@export var max_health = 100
@onready var current_health: int = max_health
@onready var health_bar: TextureProgressBar=$enemy_health_bar

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




func _physics_process(delta: float):
	manage_enemy(delta)

func manage_enemy(delta):
	if player_attackable and can_attack:
		enemy_attack()
	else:
		if can_move:
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




func enemy_movement(delta):
	if player_in_area:
		# Imposta la posizione target al player
		nav_agent.target_position = player.global_position
		
		# Ottieni il prossimo waypoint dal percorso calcolato
		if not nav_agent.is_navigation_finished():
			var next_pos = nav_agent.get_next_path_position()
			var direction = (next_pos - global_position).normalized()
			
			# Determina la direzione di movimento
			if abs(direction.x) >= abs(direction.y):
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
	else:
		play_anim(0, 0)
		velocity.x = 0
		velocity.y = 0
		
	move_and_slide()




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


func getHurt():
	print("ahia")
	print(current_health)
	current_health -= 10
	health_bar.update()
