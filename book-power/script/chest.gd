extends Node2D

@export var item_contenuto: InvItem
@export var chiave: InvItem

var player_in_area = false
var player = null

var has_obtained_object = false
var open = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if has_obtained_object:
		return
	if player_in_area:
		if Input.is_action_just_pressed("Pick_object"):
			if open:
				has_obtained_object = player.collect(item_contenuto)
			else:
				if not player.selected_item==chiave:
					print("serve una chiave per aprire")
					return
				openChest()
				has_obtained_object = player.collect(item_contenuto)
			
			if has_obtained_object:
				print("hai ottenuto un oggetto")
			else:
				print("c'è un oggetto nella chest ma l'inventario è pieno")


func openChest():
	$AnimatedSprite2D.play("opening")
	await $AnimatedSprite2D.animation_finished
	open = true



func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true
		player = body

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
