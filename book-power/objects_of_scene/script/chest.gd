extends Node2D

@export var object_contenuto: PackedScene
@export var chiave: InvItem

var player_in_area = false
var player = null

var opened = false
var offset_drop = Vector2(0, 10)

var button_visible = false

func _ready():
	$button_icon.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if opened or not player_in_area:
		return
	if player.selected_item!=chiave and button_visible:
		Global.pickDecrement()
		button_visible = false
		$button_icon.hide()
	if player.selected_item==chiave and not button_visible:
		Global.pickIncrement()
		mostra_button()
	if Input.is_action_just_pressed("Pick_object") and player.selected_item==chiave:
		openChest()


func openChest():
	$AnimatedSprite2D.play("opening")
	$ChestSound.play()
	opened = true
	await $AnimatedSprite2D.animation_finished
	dropObject()
	player.consumeItem(chiave,1)
	Global.pickDecrement()
	$button_icon.hide()


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
		if !opened and player.selected_item==chiave:
			mostra_button()
			Global.pickIncrement()


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
		$button_icon.hide()
		button_visible=false
		if !opened and player.selected_item==chiave:
			Global.pickDecrement()


func mostra_button():
	button_visible = true
	$button_icon.show()
	while player_in_area and not opened:
		if player.selected_item!=chiave:
			$button_icon.hide()
			button_visible = false
			break
		$button_icon.modulate.a = 1
		await get_tree().create_timer(0.7).timeout
		$button_icon.modulate.a = 0.5
		await get_tree().create_timer(0.5).timeout
