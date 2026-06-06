extends CharacterBody2D

class_name Player
#serve a altri nodi per identificare chi è entrato attraverso il "has_method()"
func player():
	pass

@onready var cam = $Camera2D

@export var SPEED = 70
var current_dir = "down"		#la inizializziamo giù

@export var max_health = 100
@onready var current_health: int = max_health
signal health_changed	#questo serve per aggiornare la health bar
signal death
var dead = false

@export var inv: Inv	#con questo possiamo richiamare le funzioni dell'inventario del player
@export var selected_item: InvItem 
var selected_item_index

var can_attack = true
var can_move = true
var offset_attacchi = Vector2(0, -7)
@onready var attacck_cooldown: Timer=$attackCooldown
@onready var mov_cooldown: Timer=$movementPostAttackCooldown
@onready var attacco_analisi_scena = preload("res://attacks/scenes/attacco_libro_analisi.tscn")
@onready var attacco_asd_scena = preload("res://attacks/scenes/attacco_libro_asd.tscn")
@onready var attacco_reti_scena = preload("res://attacks/scenes/attacco_libro_reti.tscn")
@onready var attacco_elettrotecnica_scena = preload("res://attacks/scenes/attacco_libro_elettrotecnica.tscn")
@onready var attacco_analisi_script = preload("res://attacks/script/attacco_libro_analisi.gd")
@onready var attacco_asd_script = preload("res://attacks/script/attacco_libro_asd.gd")
@onready var attacco_reti_script = preload("res://attacks/script/attacco_libro_reti.gd")
@onready var attacco_elettrotecnica_script = preload("res://attacks/script/attacco_libro_elettrotecnica.gd")
@onready var health_potion_script = preload("res://objects_pickable/script/health_potion.gd")


class PushData:
	var direction: Vector2
	var force: float
	var decay: float		#valori buoni sono tipo 0.9
	var duration: float

	func _init(dir: Vector2, f: float, d: float, dur: float):
		direction = dir
		force = f
		decay = d
		duration = dur
var is_being_pushed = false
var push: PushData = null

var bloccato = true

func _ready():
	Global.selected_slot_update.connect(updateSelectedItem)
	if get_parent()!=null:
		if get_parent().name == "livello_1":
			await get_tree().create_timer(4.5).timeout
			bloccato = false
			return
		if get_parent().name == "livello_0" or get_parent().name == "livello_6":
			return
	bloccato = false
	
func _physics_process(delta: float):
	if bloccato:
		return
	if GameState.in_dialogue or GameState.in_tutorial:
		play_anim(0,0)
		velocity.x = 0
		velocity.y = 0
	else:
		if Input.is_action_pressed("attacca") and can_attack:
			attacca()
		elif can_move:
			player_movement(delta)
		elif is_being_pushed:
			getPushed(delta)
	if current_health <= 0 and !dead :
		Global.emit_signal("death")
		dead = true

func player_movement(_delta):
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
		attacco_analisi()
	elif selected_item.name == "libro_asd":
		attacco_asd()
	elif selected_item.name == "libro_reti":
		attacco_reti()
	elif selected_item.name == "libro_elettrotecnica":
		attacco_elettrotecnica()
	elif selected_item.name == "health_potion":
		drink_potion()

func attacco_analisi():
	var scena_attacco = attacco_analisi_scena.instantiate()
	scena_attacco.global_position = global_position + offset_attacchi
	match current_dir:
		"right":
			scena_attacco.rotation_degrees = 0
		"left":
			scena_attacco.rotation_degrees = 180
		"up":
			scena_attacco.rotation_degrees = -90
		"down":
			scena_attacco.rotation_degrees = 90
	get_tree().current_scene.add_child(scena_attacco)
	
	set_movement_and_attack_cooldown(attacco_analisi_script.atk_cooldown, attacco_analisi_script.move_cooldown)
	play_anim(0, 1)

func attacco_asd():
	var scena_attacco = attacco_asd_scena.instantiate()
	scena_attacco.global_position = global_position + offset_attacchi
	match current_dir:
		"right":
			scena_attacco.rotation_degrees = 0
		"left":
			scena_attacco.rotation_degrees = 180
		"up":
			scena_attacco.rotation_degrees = -90
		"down":
			scena_attacco.rotation_degrees = 90
	get_tree().current_scene.add_child(scena_attacco)
	
	set_movement_and_attack_cooldown(attacco_asd_script.atk_cooldown, attacco_asd_script.move_cooldown)
	play_anim(0, 1)

func attacco_reti():
	var scena_attacco = attacco_reti_scena.instantiate()
	scena_attacco.global_position = global_position + offset_attacchi
	get_tree().current_scene.add_child(scena_attacco)
	
	set_movement_and_attack_cooldown(attacco_reti_script.atk_cooldown, attacco_reti_script.move_cooldown)
	play_anim(0, 1)

func attacco_elettrotecnica():
	var scena_attacco = attacco_elettrotecnica_scena.instantiate()
	scena_attacco.global_position = global_position + offset_attacchi + Vector2(0,-34)
	get_tree().current_scene.add_child(scena_attacco)
	
	set_movement_and_attack_cooldown(attacco_elettrotecnica_script.atk_cooldown, attacco_elettrotecnica_script.move_cooldown)
	play_anim(0, 1)

func drink_potion():
	getHealed(selected_item.health_plus)
	consume(selected_item_index)
	
	set_movement_and_attack_cooldown(health_potion_script.atk_cooldown, health_potion_script.move_cooldown)
	$AnimatedSprite2D.play("drink")

func set_movement_and_attack_cooldown(atk_cooldown, move_cooldown):
	can_attack = false
	can_move = false
	attacck_cooldown.wait_time = atk_cooldown
	mov_cooldown.wait_time = move_cooldown
	attacck_cooldown.start()  # Avvia il timer
	mov_cooldown.start()



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

func consume(indice):
	inv.delete(indice)	#lo possiamo fare perchè abbiamo fatto sopra nel codice l'export di inv

func consumeItem(item: InvItem, num_item: int):
	var i=0
	var indici_item_da_rimuovere = []
	for current_item in inv.slots:
		if item.equals(current_item.item) and indici_item_da_rimuovere.size()<num_item:
			indici_item_da_rimuovere.push_back(i)
		i+=1
	for indice in indici_item_da_rimuovere:
		consume(indice)

func updateSelectedItem(slot: InvSlot, indice):
	selected_item = slot.item
	selected_item_index = indice

func getHurt(damage):
	$AnimatedSprite2D.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1, 1, 1)
	current_health -= damage
	health_changed.emit()	#per aggiornare la health bar

func getHealed(health_plus):
	$HealthSoundEffect.play()
	for i in range(0,3):
		$AnimatedSprite2D.modulate = Color(0, 1, 0)
		await get_tree().create_timer(0.2).timeout
		$AnimatedSprite2D.modulate = Color(1, 1, 1)
		await get_tree().create_timer(0.1).timeout
	current_health += health_plus
	if current_health > max_health:
		current_health = max_health
	health_changed.emit()	#per aggiornare la health bar


func setPushed(direction: Vector2, force, decay, duration):
	can_move = false
	is_being_pushed = true
	push = PushData.new(direction, force, decay, duration)

func getPushed(delta:float):
	if push == null:
		return
	play_anim(0,0)
	velocity = push.direction.normalized() * push.force
	push.force *= push.decay		# Decadimento esponenziale
	push.duration -= delta
	
	if push.duration<=0 or push.force<1:
		is_being_pushed = false
		can_move = true
		push = null
	
	move_and_slide()


func _on_attack_cooldown_timeout() -> void:
	can_attack = true

func _on_movement_post_attack_cooldown_timeout() -> void:
	can_move = true



func move_camera():
	if get_parent() != null:
		if get_parent().name == "livello_0" or get_parent().name == "livello_6" :
			var tween = create_tween()
			# Muove la camera verso il player
			tween.tween_interval(2.0)
			tween.tween_property(cam, "global_position", global_position+Vector2(10,-20), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			# Zoom contemporaneamente
			tween.parallel().tween_property(cam, "zoom", Vector2(8, 8), 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func zoom_camera_on_player():
	if get_parent() != null:
		if get_parent().name == "livello_0":
			var tween = create_tween()
			tween.parallel().tween_property(cam, "zoom", Vector2(90, 90), 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func make_sit():
	$AnimatedSprite2D.animation = "right_sit"
	$AnimatedSprite2D.frame = 0

func make_sleep():
	$AnimatedSprite2D.play("right_sleeping")
