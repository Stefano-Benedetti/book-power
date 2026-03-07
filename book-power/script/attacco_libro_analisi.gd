extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()
	await get_tree().create_timer(0.8).timeout
	queue_free()
