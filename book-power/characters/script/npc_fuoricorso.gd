extends CharacterBody2D

class_name NPC
#serve a altri nodi per identificare chi è entrato attraverso il "has_method()"
func enemy():
	pass

signal update_quest

@export var dropped_object: PackedScene
var offset_drop = Vector2(0, 20)
var dropped = false

var player_in_talkArea = false
var player = null

const SPEED = 60
var current_dir = "down"		#la inizializziamo giù

@export var max_health = 100
@onready var current_health: int = max_health
@onready var health_bar: TextureProgressBar=$bat_health_bar
var dead = false

var fighting = false
var can_attack = true
var can_move = true
var sosta = false
@onready var attacck_cooldown: Timer=$attackCooldown
@onready var mov_cooldown: Timer=$movementPostAttackCooldown

@onready var attacco_analisi = preload("res://attacks/scenes/attacco_analisi_boss.tscn")
@onready var attacco_asd_around = preload("res://attacks/scenes/attacco_asd_around_boss.tscn")
@onready var attacco_reti = preload("res://attacks/scenes/attacco_reti_boss.tscn")

var player_in_detectionArea = false
@onready var nav_agent = $NavigationAgent2D  # Collegamento al nodo NavigationAgent2D
var spawn_point = null
var escaping_player = false
var going_random = true
@export var repath_distance: float = 5.0 # evita ricalcoli se player quasi fermo
var _last_target: Vector2
var fermo = true



func _ready():
	play_anim(0,0)
	randomize()
	player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	if fighting:
		fight_behavior(_delta)
		return
	if player_in_talkArea:
		if Input.is_action_just_pressed("Pick_object"):
			Global.emit_signal("start_dialog")


func _on_talk_area_body_entered(body: Node2D) -> void:
	if fighting:
		return
	if body.has_method("player"):
		update_quest.emit()
		player_in_talkArea = true
		player = body

func _on_talk_area_body_exited(body: Node2D) -> void:
	if fighting:
		return
	if body.has_method("player"):
		player_in_talkArea = false

func dropObject():
	if dropped_object == null or dropped:
		return
	var scena_dropped_object = dropped_object.instantiate()
	get_parent().add_child(scena_dropped_object)
	scena_dropped_object.global_position = global_position + offset_drop
	dropped = true


func fight_behavior(_delta):
	if dead:
		return
	elif current_health<=0:
		die()
	elif can_attack:
		NPC_attack()
	elif can_move:
		NPC_movement(_delta)

func NPC_attack():
	var animazione_attacco = ""
	var tipo_attacco = randi_range(0, 2)
	fermo = true
	can_attack = false
	can_move = false
	#decide che attacco a fare anche in base alla distanza dal player
	var dist_to_player = global_position.distance_to(player.global_position)
	if dist_to_player<=40: #cioè se il player è vicino
		tipo_attacco = 2
	elif dist_to_player<=80:	
		tipo_attacco = randi_range(0, 1)
	else:
		tipo_attacco = randi_range(1, 2)
	match tipo_attacco:
		0:
			generate_attacco_analisi()
			animazione_attacco = "attacco_analisi"
			$movementPostAttackCooldown.wait_time = 1
			$attackCooldown.wait_time = 2
		1:
			generate_bomb_packet()
			animazione_attacco = "attacco_reti"
			$movementPostAttackCooldown.wait_time = 1
			$attackCooldown.wait_time = 3
		2:
			generate_redblackTree_around()
			animazione_attacco = "attacco_asd"
			$movementPostAttackCooldown.wait_time = 1.5
			$attackCooldown.wait_time = 3

	attacck_cooldown.start()  # Avvia il timer
	mov_cooldown.start()
	$AnimatedSprite2D.play(animazione_attacco)
	#crea attacco...

func generate_attacco_analisi():
	var coseni_verticali = randi_range(0, 1) == 1
	var generation_points = []
	if coseni_verticali:
		generation_points = get_tree().get_nodes_in_group("spawn_attacco_analisi_verticale")
	else:
		generation_points = get_tree().get_nodes_in_group("spawn_attacco_analisi_orizzontale")
	var coseni_da_generare = randi_range(4, 7)
	var used_points = []
	for i in range(0, coseni_da_generare):
		var temp_point = generation_points.pick_random()
		used_points.append(temp_point)
		generation_points.erase(temp_point) #per evitare che riprenda casualmente lo stesso punto di prima
	for point in used_points:
		var scena_attacco_analisi = attacco_analisi.instantiate()
		scena_attacco_analisi.global_position = point.global_position
		if coseni_verticali:
			scena_attacco_analisi.rotation = deg_to_rad(90)
		get_tree().current_scene.add_child(scena_attacco_analisi)

func generate_redblackTree_around():
	var scena_attacco = attacco_asd_around.instantiate()
	scena_attacco.global_position = global_position
	get_tree().current_scene.add_child(scena_attacco)

func generate_bomb_packet():
	var scena_attacco = attacco_reti.instantiate()
	scena_attacco.global_position = global_position
	var dir = (player.global_position - global_position).normalized()
	scena_attacco.direction = dir
	get_tree().current_scene.add_child(scena_attacco)

#restituisce null se si deve fermare, altrimenti restituisce il target
func calcolo_target():
	var target: Vector2
	if sosta:
		return null
	if nav_agent.is_navigation_finished():
		sosta = true
		escaping_player = false
		going_random = false
		$movementSost.start()
	if escaping_player:
		return _last_target
	elif player_in_detectionArea:
		#scappa
		escaping_player = true
		going_random = false
		var escape_from = player.global_position
		var destinations = get_tree().get_nodes_in_group("casual_boss_destination")
		var candidatiX = []
		var candidatiY = []
		var candidatiXY = []
		for dest in destinations:
			var count = 0
			if dest.global_position.distance_to(global_position) < 30:
				continue
			if dest.global_position.x < global_position.x and global_position.x < escape_from.x:
				candidatiX.append(dest)
				count +=1
			elif dest.global_position.x > global_position.x and global_position.x > escape_from.x:
				candidatiX.append(dest)
				count +=1
			if dest.global_position.y < global_position.y and global_position.y < escape_from.y:
				candidatiY.append(dest)
				count +=1
			elif dest.global_position.y > global_position.y and global_position.y > escape_from.y:
				candidatiY.append(dest)
				count +=1
			if count == 2:
				candidatiXY.append(dest)
		if not candidatiXY.is_empty():
			target = candidatiXY.pick_random().global_position
		elif abs(escape_from.x-global_position.x) > abs(escape_from.y-global_position.y):
			if not candidatiX.is_empty():
				target = candidatiX.pick_random().global_position
			elif not candidatiY.is_empty():
				target = candidatiY.pick_random().global_position
		elif abs(escape_from.x-global_position.x) < abs(escape_from.y-global_position.y):
			if not candidatiY.is_empty():
				target = candidatiY.pick_random().global_position
			elif not candidatiX.is_empty():
				target = candidatiX.pick_random().global_position
		else:
			target = destinations.pick_random().global_position
	elif not going_random:
		#vai in un punto casuale
		escaping_player = false
		going_random = true
		var destinations = get_tree().get_nodes_in_group("casual_boss_destination")
		target = destinations.pick_random().global_position
	else:
		return _last_target
	
	return target

func NPC_movement(_delta):
	var target = calcolo_target()
	if target == null:
		fermo = true
		velocity = Vector2.ZERO
		play_anim(0,0)
		move_and_slide()
		return
	
	if abs(_last_target.x-target.x)>=repath_distance or abs(_last_target.y-target.y)>=repath_distance:
		nav_agent.target_position = target #aggiorno il path
		_last_target = target
	
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	
	if fermo:
		fermo=false
		mod_dir_and_velocity(direction, 1)
	elif abs(abs(direction.x) - abs(direction.y)) > 0.5:
		mod_dir_and_velocity(direction, 0)
	
	play_anim(1,0)
	move_and_slide()

func mod_dir_and_velocity(direction, era_fermo):
	if era_fermo == 1:
		if abs(direction.x) > abs(direction.y):
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
	else:
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



func _on_player_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_detectionArea = true
		player = body

func _on_player_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_detectionArea = false

func _on_attack_cooldown_timeout():
	can_attack = true

func _on_movement_post_attack_cooldown_timeout() -> void:
	can_move = true

func _on_movement_sost_timeout() -> void:
	sosta = false

func getHurt(damage):
	$AnimatedSprite2D.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1, 1, 1)
	current_health -= damage
	health_bar.update()

func die():
	dead = true
	Global.emit_signal("morte_fuoricorso")
	$AnimatedSprite2D.play("die")
	await get_tree().create_timer(2.0).timeout #crea un timer di due secondi e aspetta la fine
	dropObject()
	queue_free()
