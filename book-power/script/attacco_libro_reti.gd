extends CharacterBody2D

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const DAMAGE = 50
var speed = 150
var target: Node2D = null
var exploding = false
var explosion_distance = 10


func _ready():
	find_closest_enemy()

func find_closest_enemy():
	var closest = null
	var dist = INF
	for e in get_tree().get_nodes_in_group("enemies"):
		if !is_instance_valid(e):
			continue
		var d = global_position.distance_to(e.global_position)
		if d < dist:
			dist = d
			closest = e
	target = closest
	if target:
		agent.target_position = target.global_position
	else:
		queue_free()


func _physics_process(delta):
	if exploding:
		return

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

	sprite.play("esplodi")

	await sprite.animation_finished

	queue_free()
