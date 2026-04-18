extends CharacterBody2D

class_name Bat
#serve a altri nodi per identificare chi è entrato attraverso il "has_method()"
func enemy():
	pass

const SPEED = 80
var current_dir = "down"		#la inizializziamo giù

@export var dropped_object: PackedScene
var offset_drop = Vector2(0, -3)

@export var max_health = 100
@onready var current_health: int = max_health
@onready var health_bar: TextureProgressBar=$bat_health_bar
var dead = false

#variabili per collegarsi al player
var player_in_area = false
var player = null

@export var damage = 5
var spostamento_attacco = 4
var player_attackable = false
var can_attack = true
var can_move = true
@onready var attacck_cooldown: Timer=$attackCooldown
@onready var mov_cooldown: Timer=$movementPostAttackCooldown


@onready var nav_agent = $NavigationAgent2D  # Collegamento al nodo NavigationAgent2D

var spawn_point = null
var going_to_spawn = true

#@export var nav_group: int = 0
@export var repath_distance: float = 10.0 # evita ricalcoli se player quasi fermo
var _last_target: Vector2
var fermo = true


func _ready():
	randomize()
	spawn_point = global_position
	_last_target = global_position

func _physics_process(delta: float):
	manage_enemy(delta)

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

func enemy_attack():
	can_attack = false
	can_move = false
	player.getHurt(damage)
	attacck_cooldown.start()  # Avvia il timer
	mov_cooldown.start()
	if current_dir == "left":
		global_position += Vector2(-spostamento_attacco, 0)
		await get_tree().create_timer(0.2).timeout
		global_position -= Vector2(-spostamento_attacco, 0)
	elif current_dir == "right":
		global_position += Vector2(spostamento_attacco, 0)
		await get_tree().create_timer(0.2).timeout
		global_position -= Vector2(spostamento_attacco, 0)
	elif current_dir == "up":
		global_position += Vector2(0, -spostamento_attacco)
		await get_tree().create_timer(0.2).timeout
		global_position -= Vector2(0, -spostamento_attacco)
	elif current_dir == "down":
		global_position += Vector2(0, spostamento_attacco)
		await get_tree().create_timer(0.2).timeout
		global_position -= Vector2(0, spostamento_attacco)


func is_point_reachable(target_point: Vector2, tolerance: float = 2.0) -> bool:
	var map = nav_agent.get_navigation_map()
	var closest = NavigationServer2D.map_get_closest_point(map, target_point)
	return closest.distance_to(target_point) <= tolerance


#restituisce null se non deve ricalcolare, altrimenti restituisce il target
func calcolo_target():
	var target: Vector2
	if player_in_area:
		going_to_spawn = false
		target = player.global_position
		# se sei vicino al player non mandare un nuovo target
		if abs(global_position.x-target.x) < 10 and abs(global_position.y-target.y) < 10:
			return null
	elif not going_to_spawn or (going_to_spawn and nav_agent.is_navigation_finished()):
		going_to_spawn = true
		var raggiungibile = false
		var tentativi = 0
		var max_tentativi = 20
		while not raggiungibile and tentativi < max_tentativi:
			target = Vector2(
				randi_range(spawn_point.x-60, spawn_point.x+60),
				randi_range(spawn_point.y-60, spawn_point.y+60)
			)
			raggiungibile = is_point_reachable(target)
			tentativi += 1
		if not raggiungibile:
			return spawn_point  # fallback sicuro
	else:
		return _last_target
	
	return target
	
	#var target: Vector2
	#if player_in_area:
		#target = player.global_position
	#else:
		#var raggiungibile = false
		#while not raggiungibile:
			#target = Vector2(randi_range(spawn_point.x-10, spawn_point.x+10), randi_range(spawn_point.y-10, spawn_point.y+10))
			#raggiungibile = is_point_reachable(target)
	#
	#
	## se sei vicino al target non mandare un nuovo target
	#if abs(global_position.x-target.x) < 10 and abs(global_position.y-target.y) < 10:
		#return null
	#
	#return target


#non basta che una delle due direzioni sia maggiore dell'altra
#deve essere proprio dominante (> di almento 0,5) in questo
#modo comunque non esce dal percorso, perchè quando si avvicina
#molto a un ostacolo (area non camminabile) la direzione dominan.
#sarà quella che gli farà cambiare la direzione.
#NOTA: finchè non cambia la direzione dominan. lui cammina sempre
#nella stessa direzione
func enemy_movement(delta):
	var target = calcolo_target()
	if target == null:
		fermo = true
		play_anim(0, 0)
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if abs(_last_target.x-target.x)>=repath_distance or abs(_last_target.y-target.y)>=repath_distance:
		nav_agent.target_position = target #aggiorno il path
		_last_target = target
	
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	
	if fermo:
		fermo=false
		mod_dir_and_velocity(direction)
	elif abs(abs(direction.x) - abs(direction.y)) > 0.5:
		mod_dir_and_velocity(direction)

	play_anim(1, 0)
	move_and_slide()



func mod_dir_and_velocity(direction):
	if abs(direction.x) > abs(direction.y):
		#if abs(direction.x) > 0.5:
		if direction.x > 0:
			current_dir = "right"
			velocity = Vector2(SPEED, 0)
		else:
			current_dir = "left"
			velocity = Vector2(-SPEED, 0)
	else:
		if direction.y > 0:
			current_dir = "down"
			velocity = Vector2(0, SPEED)
		else:
			current_dir = "up"
			velocity = Vector2(0, -SPEED)


#funzione per gestire le animazioni del player, movement=1 => ci stiamo muovendo
func play_anim(movement, attaccando):
	var anim = $AnimatedSprite2D
	if current_dir == "right":
		anim.play("right_fly")
	if current_dir == "left":
		anim.play("left_fly")
	if current_dir == "up":
		anim.play("rear_fly")
	if current_dir == "down":
		anim.play("front_fly")




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
	$AnimatedSprite2D.play("die")
	$AnimatedSprite2D.global_position.y += 8
	await get_tree().create_timer(2.0).timeout #crea un timer di due secondi e aspetta la fine
	dropObject()
	queue_free()
