extends Node2D

@export var object_contenuto: PackedScene
@export var chiave: InvItem

var player_in_area = false
var player = null

var opened = false
var offset_drop = Vector2(0, 10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if opened:
		return
	if player_in_area and Input.is_action_just_pressed("Pick_object"):
		if not player.selected_item==chiave:
			print("serve una chiave per aprire")
			return
		openChest()


func openChest():
	$AnimatedSprite2D.play("opening")
	await $AnimatedSprite2D.animation_finished
	dropObject()
	opened = true
	player.consumeItem(chiave,1)


func dropObject():
	if object_contenuto == null:
		return
	var scena_dropped_object = object_contenuto.instantiate()
	get_parent().add_child(scena_dropped_object)
	scena_dropped_object.global_position = global_position + offset_drop

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true
		player = body

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
