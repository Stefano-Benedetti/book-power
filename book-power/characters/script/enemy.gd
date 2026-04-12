extends CharacterBody2D

class_name Enemy
#serve a altri nodi per identificare chi è entrato attraverso il "has_method()"
func enemy():
	pass

const SPEED = 30
var current_dir = "down"		#la inizializziamo giù

@export var dropped_object: PackedScene
var offset_drop = Vector2(0, -3)

@export var max_health = 100
@onready var current_health: int = max_health
@onready var health_bar: TextureProgressBar=$enemy_health_bar
var dead = false

#variabili per collegarsi al player
var player_in_area = false
var player = null

@export var damage = 10
var player_attackable = false
var can_attack = true
var can_move = true
@onready var attacck_cooldown: Timer=$attackCooldown
@onready var mov_cooldown: Timer=$movementPostAttackCooldown
@onready var nuvoletta: Control=$enemy_cloud

@onready var nav_agent = $NavigationAgent2D  # Collegamento al nodo NavigationAgent2D

var spawn_point = null

@export var nav_group: int = 0
@export var repath_distance: float = 16.0 # evita ricalcoli se player quasi fermo
var _last_target: Vector2
var _nav_manager: AINavManager = null

func _ready():
	nav_group = randi() % 3
	
	spawn_point = global_position
	nuvoletta.visible = false
	_last_target = global_position

	# registra al manager se esiste nel livello
	# (nome nodo: "ai_nav_manager" in livello_1)
	if get_tree().current_scene and get_tree().current_scene.has_node("ai_nav_manager"):
		_nav_manager = get_tree().current_scene.get_node("ai_nav_manager")
		_nav_manager.register_enemy(self, nav_group)

func _physics_process(delta: float):
	manage_enemy(delta)

func _exit_tree() -> void:
	if _nav_manager != null:
		_nav_manager.unregister_enemy(self, nav_group)


func nav_tick() -> void:
	if dead:
		return
	# se sei fermo allo spawn e player non in area, non aggiornare path
	if abs(position.x-spawn_point.x) < 20 and abs(position.y-spawn_point.y) < 20 and !player_in_area:
		return
	var target: Vector2
	if player_in_area and player != null:
		target = player.global_position
	else:
		target = spawn_point
	if target.distance_to(_last_target) < repath_distance:
		return
	_last_target = target
	nav_agent.target_position = target


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
	player.getHurt(damage)
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
	if abs(position.x-spawn_point.x) < 20 and abs(position.y-spawn_point.y) < 20 and !player_in_area:
		play_anim(0, 0)
		velocity = Vector2.ZERO
		move_and_slide()
		return

	#scegli target
	var target: Vector2
	if player_in_area and player != null:
		target = player.global_position
	else:
		target = spawn_point

	#ricalcolo PATH SOLO a turno (1/3 dei frame)
	var turn := int(Engine.get_physics_frames() % 3)
	if turn == posmod(nav_group, 3):
		# evita ricalcoli inutili se il target si è mosso poco
		if target.distance_to(_last_target) >= repath_distance:
			_last_target = target
			nav_agent.target_position = target
	else:
		# fallback: se il path è finito/mai calcolato, aggiorna comunque (così non si “blocca”)
		if nav_agent.is_navigation_finished():
			_last_target = target
			nav_agent.target_position = target

	#movimento usando il path corrente
	if nav_agent.is_navigation_finished():
		play_anim(0, 0)
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()

	if abs(abs(direction.x) - abs(direction.y)) > 0.5:
		if abs(direction.x) > 0.5:
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

	play_anim(1, 0)
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
