extends Node2D

@export var object_contenuto: PackedScene
@export var chiave: InvItem

var player_in_area = false
var player = null

var opened = false
var offset_drop = Vector2(0, 10)

var icon_enabled = false

var button_visible = false

func _ready():
	$button_icon.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if opened:
		return
	if player_in_area and player.selected_item==chiave and not button_visible:
		mostra_button()
	if player_in_area and Input.is_action_just_pressed("Pick_object"):
		if not player.selected_item==chiave:
			return
		openChest()
	if player_in_area and player.selected_item==chiave and !icon_enabled:
		Global.pickIncrement()
		icon_enabled = true
	if player_in_area and player.selected_item!=chiave and icon_enabled:
		Global.pickDecrement()
		icon_enabled = false


func openChest():
	$AnimatedSprite2D.play("opening")
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
		if player.selected_item==chiave and !opened:
			mostra_button()
			Global.pickIncrement()
			icon_enabled = true

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
		$button_icon.hide()
		if !opened:
			Global.pickDecrement()
			icon_enabled = false


func mostra_button():
	button_visible = true
	$button_icon.show()
	while player_in_area and not opened:
		if player.selected_item!=chiave:
			button_visible = false
			$button_icon.hide()
			break
		$button_icon.modulate.a = 1
		await get_tree().create_timer(0.7).timeout
		$button_icon.modulate.a = 0.5
		await get_tree().create_timer(0.5).timeout
