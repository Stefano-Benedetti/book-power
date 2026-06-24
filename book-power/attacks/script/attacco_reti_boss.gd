extends Node2D

const DAMAGE = 12
var speed = 400

var launched = false
var hittato = false

var player_in_explosionArea = false
var player: CharacterBody2D

var direction: Vector2 = Vector2.ZERO

@onready var traiettoria = $traiettoria


func _ready():
	traiettoria.rotation = direction.angle()
	$AnimatedSprite2D.hide()
	for i in range(0,2):
		$traiettoria/ColorRect.show()
		await get_tree().create_timer(0.2).timeout
		$traiettoria/ColorRect.hide()
		await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.show()
	$AnimatedSprite2D.play("in_movement")
	launched = true
	$FreesoundCommunityTickingBomb90319.play()
	await get_tree().create_timer(1.5).timeout
	queue_free()


func _process(delta):
	if not launched or hittato:
		return
	if player_in_explosionArea and not hittato:
		explode()
	position += direction * speed * delta


func explode():
	$FreesoundCommunityTickingBomb90319.stop()
	hittato = true
	player.getHurt(DAMAGE)
	$AnimatedSprite2D.play("explosion")
	$LumoraStudiosPixelExplosion319166.play()
	await $AnimatedSprite2D.animation_finished
	queue_free()

func _on_explosion_area_body_entered(body: Node2D) -> void:
	if not body.has_method("player"):
		return
	player = body
	player_in_explosionArea = true
	
