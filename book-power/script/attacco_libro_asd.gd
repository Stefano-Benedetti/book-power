extends Node2D

const DAMAGE = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()
	await get_tree().create_timer(0.8).timeout
	queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy.has_method("enemy"):	#verifico se è effettivamente un nemico
		enemy.getHurt(DAMAGE)
