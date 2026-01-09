extends Control

@onready var inv: Inv = preload("res://inventory/player_inventory.tres")
@onready var item_visual: Sprite2D = $CenterContainer/Panel/item_display


func _ready():
	Global.selected_slot_update.connect(update)

#aggiorna l'oggetto all'interno dello slot
func update(slot: InvSlot):
	if !slot.item:
		item_visual.visible = false
	else:
		item_visual.visible = true
		item_visual.texture = slot.item.texture
