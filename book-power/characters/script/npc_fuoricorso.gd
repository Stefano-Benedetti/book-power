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

var SPEED = 60
var current_dir = "down"		#la inizializziamo giù

@export var max_health = 700
@onready var current_health: int = max_health
@onready var health_bar: TextureProgressBar=$CanvasLayer/Container/TextureRect/HBoxContainer/MarginContainer/healthBar
@onready var health_bar_UI = $CanvasLayer
var dead = false

@onready var collisionShape = $CollisionShape2D
var fighting = false
var can_attack = true
var can_spawn_enemy = false
var can_move = true
var sosta = false
@onready var attacck_cooldown: Timer=$attackCooldown
@onready var mov_cooldown: Timer=$movementPostAttackCooldown
@onready var spawnEnemy_cooldown: Timer=$SpawnEnemyCooldown

@onready var attacco_analisi = preload("res://attacks/scenes/attacco_analisi_boss.tscn")
@onready var attacco_asd_around = preload("res://attacks/scenes/attacco_asd_around_boss.tscn")
@onready var attacco_reti = preload("res://attacks/scenes/attacco_reti_boss.tscn")
@onready var enemy_to_spawn = preload("res://characters/scenes/enemy_spawnedFromNPC.tscn")

var player_in_detectionArea = false
@onready var nav_agent = $NavigationAgent2D  # Collegamento al nodo NavigationAgent2D
var spawn_point = null
var escaping_player = false
var going_random = true
@export var repath_distance: float = 5.0 # evita ricalcoli se player quasi fermo
var _last_target: Vector2
var fermo = true

var electric_form = false


func _ready():
	$button_icon.hide()
	health_bar_UI.hide()
	play_anim(0,0)
	randomize()
	player = get_tree().get_first_node_in_group("player")
	$AnimatedSprite2D/electric_particles.hide()
	spawnEnemy_cooldown.start()

func _process(_delta: float) -> void:
	if fighting:
		fight_behavior(_delta)
		return
	if player_in_talkArea:
		if Global.pick_counter==1 and Input.is_action_just_pressed("Pick_object"):
			if not GameState.in_dialogue:
				Global.emit_signal("start_dialog")


func _on_talk_area_body_entered(body: Node2D) -> void:
	if fighting:
		return
	if body.has_method("player"):
		update_quest.emit()
		player_in_talkArea = true
		player = body
		mostra_button()
		Global.pickIncrement()

func _on_talk_area_body_exited(body: Node2D) -> void:
	if fighting:
		return
	if body.has_method("player"):
		player_in_talkArea = false
		$button_icon.hide()
		Global.pickDecrement()

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
		NPC_attack(_delta)
	elif can_move:
		NPC_movement(_delta)

func NPC_attack(_delta):
	var animazione_attacco = ""
	var tipo_attacco
	fermo = true
	can_attack = false
	can_move = false
	var no_cooldown = false
	
	if can_spawn_enemy:
		spawn_enemy()
		animazione_attacco = "attacco_analisi"
		$movementPostAttackCooldown.wait_time = 1
		$attackCooldown.wait_time = 2
		$BossSummon.play()
	else:
		#decide che attacco fare anche in base alla distanza dal player
		var dist_to_player = global_position.distance_to(player.global_position)
		var attacchi_candidati = []
		if dist_to_player<=40: #cioè se il player è vicino
			attacchi_candidati.append(2)
			attacchi_candidati.append(3)
		elif dist_to_player<=60:	
			attacchi_candidati.append(1)
			attacchi_candidati.append(2)
			attacchi_candidati.append(3)
		elif dist_to_player<=80:	
			attacchi_candidati.append(1)
			attacchi_candidati.append(2)
		else:
			attacchi_candidati.append(0)
			attacchi_candidati.append(1)
		tipo_attacco = attacchi_candidati.pick_random()
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
			3:
				electric_movement()
				animazione_attacco = "electricity_form"
				no_cooldown = true	#non avvio i timer che invece saranno avviati solo da electric_movement() a fine movimento
	
	if ! no_cooldown:
		attacck_cooldown.start()  # Avvia il timer
		mov_cooldown.start()
	$AnimatedSprite2D.play(animazione_attacco)

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

func electric_movement():
	var offset_normale = $AnimatedSprite2D.offset.y
	$AnimatedSprite2D/electric_particles.show()
	$BossElectricSound.play()
	$AnimatedSprite2D.offset.y += -offset_normale
	electric_form = true
	var moltiplicare_speed = 3
	SPEED = SPEED*moltiplicare_speed
	#trovo la destinazione più lontana
	var destinations = get_tree().get_nodes_in_group("casual_boss_destination")
	var far_dest = destinations[0]
	for dest in destinations:
		if global_position.distance_to(dest.global_position) > global_position.distance_to(far_dest.global_position):
			far_dest = dest
	nav_agent.target_position = far_dest.global_position
	await get_tree().create_timer(0.2).timeout
	while ! nav_agent.is_navigation_finished():
		var next_pos = nav_agent.get_next_path_position()
		var direction = (next_pos - global_position).normalized()
		mod_dir_and_velocity(direction, 1)
		move_and_slide()
		await get_tree().process_frame #altrimenti lo esegue velocissimo
	SPEED = SPEED/moltiplicare_speed
	await get_tree().create_timer(0.5).timeout
	$AnimatedSprite2D.offset.y += offset_normale
	
	electric_form = false
	$AnimatedSprite2D/electric_particles.hide()
	$BossElectricSound.stop()
	$movementPostAttackCooldown.wait_time = 0.5
	$attackCooldown.wait_time = 1
	attacck_cooldown.start()  # Avvia il timer
	mov_cooldown.start()

func spawn_enemy():
	can_spawn_enemy = false
	var generation_point = get_tree().get_nodes_in_group("casual_enemy_spawn_points").pick_random()
	var scena_enemy = enemy_to_spawn.instantiate()
	scena_enemy.global_position = generation_point.global_position
	scena_enemy.player = player
	get_tree().current_scene.add_child(scena_enemy)

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
		if not electric_form:
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
	
	if not electric_form:
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

func _on_spawn_enemy_cooldown_timeout() -> void:
	can_spawn_enemy = true

func _on_movement_sost_timeout() -> void:
	sosta = false

func set_on_fightmode():
	if dead:
		return
	fighting = true
	self.add_to_group("enemies")
	collisionShape.queue_free()
	health_bar_UI.show()

func set_on_talkmode():
	fighting = false
	self.remove_from_group("enemies")

func getHurt(damage):
	if fighting:
		$AnimatedSprite2D.modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.1).timeout
		$AnimatedSprite2D.modulate = Color(1, 1, 1)
		current_health -= damage
		health_bar.update()

func die():
	dead = true
	Global.emit_signal("morte_fuoricorso")
	$AnimatedSprite2D.play("die")
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.name != self.name:
			enemy.queue_free()
	await get_tree().create_timer(2.0).timeout #crea un timer di due secondi e aspetta la fine
	dropObject()


func mostra_button():
	$button_icon.show()
	while player_in_talkArea:
		$button_icon.modulate.a = 1
		await get_tree().create_timer(0.7).timeout
		$button_icon.modulate.a = 0.5
		await get_tree().create_timer(0.5).timeout
