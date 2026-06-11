extends Node2D

const DAMAGE = 8
var damage_fase = false

var player_in_damageArea = false
var player: CharacterBody2D

var hittato = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.hide()
	for i in range(0,3):
		$ColorRect.show()
		await get_tree().create_timer(0.3).timeout
		$ColorRect.hide()
		await get_tree().create_timer(0.2).timeout
	$AnimatedSprite2D.show()
	$AnimatedSprite2D.play()
	$WaveTone.seek(0.25)
	$WaveTone.play()
	damage_fase = true
	await get_tree().create_timer(1.5).timeout
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
