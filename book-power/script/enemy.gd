extends CharacterBody2D

#serve a altri nodi per identificare chi è entrato attraverso il "has_method()"
func enemy():
	pass

#variabili per collegarsi al player
var player_in_area = false
var player = null

const SPEED = 30
var current_dir = "down"		#la inizializziamo giù

var obstacle_detected = false


func _physics_process(delta: float):
	enemy_movement(delta)
	
func enemy_movement(delta):
	if player_in_area:
		var deltax = player.position.x - self.position.x
		var deltay = player.position.y - self.position.y
		
		if abs(deltax) >= abs(deltay):	#mi muovo sulla x
			if deltax > 0:
				current_dir = "right"
				play_anim(1)
				velocity.x = SPEED
				velocity.y = 0
			elif deltax < 0:
				current_dir = "left"
				play_anim(1)
				velocity.x = -SPEED
				velocity.y = 0
			
		else:	#mi muovo sulla y
			if deltay > 0:
				current_dir = "down"
				play_anim(1)
				velocity.x = 0
				velocity.y = SPEED
			elif deltay < 0:
				current_dir = "up"
				play_anim(1)
				velocity.x = 0
				velocity.y = -SPEED
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
