extends CharacterBody2D

#serve a altri nodi per identificare chi è entrato attraverso il "has_method()"
func enemy():
	pass

const SPEED = 30
var current_dir = "down"		#la inizializziamo giù

#variabili per collegarsi al player
var player_in_area = false
var player = null
var player_attackable = false

@onready var nav_agent = $NavigationAgent2D  # Collegamento al nodo NavigationAgent2D


func _physics_process(delta: float):
	enemy_movement(delta)
	
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
			
			play_anim(1)
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
