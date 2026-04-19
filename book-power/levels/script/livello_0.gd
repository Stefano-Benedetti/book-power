extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$player.cam.global_position = $Node2D.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
