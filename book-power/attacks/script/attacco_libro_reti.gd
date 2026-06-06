extends CharacterBody2D

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosion_area: Area2D = $Area2D

const DAMAGE = 50
static var atk_cooldown = 1
static var move_cooldown = 1

var speed = 100
var target: Node2D = null
var exploding = false
var explosion_distance = 5

var in_cave: bool = false

func _ready():
	if get_parent()!=null:
		if get_parent().name == "livello_4":
			in_cave = get_parent().player_in_cave
	find_closest_enemy()
	await get_tree().create_timer(1.5).timeout
	if !exploding :
		explode()

func find_closest_enemy():
	var closest = null
	var dist = INF
	for e in get_tree().get_nodes_in_group("enemies"):
		if !is_instance_valid(e):
			continue
		if e.dead: #non accoppiarlo con l'if sopra o può dare errori con null
			continue
		if get_parent()!=null:
			if get_parent().name == "livello_4":
				if in_cave!=e.is_in_group("in_cave"):
					continue
		var d = global_position.distance_to(e.global_position)
		if d < dist:
			dist = d
			closest = e
	target = closest
	if target:
		agent.target_position = target.global_position
		$timer_sonoro.play()
	else:
		queue_free()



func _physics_process(delta):
	if exploding:
		return
	movement()


func movement():
	sprite.play("in_movement")
	# se il nemico non è più in memoria (è morto), trovane un altro
	if !is_instance_valid(target):
		find_closest_enemy()
		return
	
	# aggiorna il target continuamente
	agent.target_position = target.global_position

	# esplode se vicino
	if global_position.distance_to(target.global_position) < explosion_distance:
		explode()
		return

	# movimento lungo il path
	var next_pos = agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()

	velocity = direction * speed
	move_and_slide()

func explode():
	exploding = true
	velocity = Vector2.ZERO
	# attiva l'area e rileva i nemici
	explosion_area.monitoring = true
	var areas = explosion_area.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("enemies_hitbox"):
			var enemy = area.get_parent()
			enemy.getHurt(DAMAGE)
	$timer_sonoro.stop()
	$esplosione.play()
	sprite.play("explosion")
	await sprite.animation_finished
	queue_free()
