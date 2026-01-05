extends Node2D


var player_in_area = false
@export var item: InvItem
var player = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in_area:
		if Input.is_action_just_pressed("Pick_object"):
			player.collect(item)
			queue_free()


func _on_pickable_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true
		player = body


func _on_pickable_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
