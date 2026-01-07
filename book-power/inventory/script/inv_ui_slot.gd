extends Panel

signal slot_premuto

#chiamiamo nel codice item_display col nome di item_visual
@onready var item_visual: Sprite2D = $TouchScreenButton/CenterContainer/Panel/item_display
@onready var button: TouchScreenButton = $TouchScreenButton

@export var nonSelected_texture: Texture2D
@export var selected_texture: Texture2D

@export var slot_index: int

#aggiorna l'oggetto all'interno dello slot
func update(slot: InvSlot):
	if !slot.item:
		item_visual.visible = false
	else:
		item_visual.visible = true
		item_visual.texture = slot.item.texture


func select():
	button.texture_normal = selected_texture

func deselect():
	button.texture_normal = nonSelected_texture


func _on_touch_screen_button_pressed() -> void:
	emit_signal("slot_premuto", slot_index)
