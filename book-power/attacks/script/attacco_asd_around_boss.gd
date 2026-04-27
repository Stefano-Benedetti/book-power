extends Node2D

const DAMAGE = 50
var damage_fase = false

var player_in_damageArea = false
var player: CharacterBody2D

var hittato = false

@onready var animatedSprites = [$AnimatedSprite2D,$AnimatedSprite2D2,$AnimatedSprite2D3,$AnimatedSprite2D4]

# Called when the node enters the scene tree for the first time.
func _ready():
	for animatedSprite in animatedSprites:
		animatedSprite.hide()
	for i in range(0,3):
		$ColorRect.show()
		print("a")
		await get_tree().create_timer(0.2).timeout
		$ColorRect.hide()
		await get_tree().create_timer(0.1).timeout
	for animatedSprite in animatedSprites:
		animatedSprite.show()
		animatedSprite.play()
	damage_fase = true
	await get_tree().create_timer(0.8).timeout
	queue_free()

func _process(delta: float) -> void:
	if hittato:
		return
	if player_in_damageArea and damage_fase:
		player.getHurt(DAMAGE)
		hittato = true


func _on_damage_area_body_entered(body: Node2D) -> void:
	if not body.has_method("player"):
		return
	player_in_damageArea = true
	player = body

func _on_damage_area_body_exited(body: Node2D) -> void:
	if not body.has_method("player"):
		return
	player_in_damageArea = false
