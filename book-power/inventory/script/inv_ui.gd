extends Control

#segnale trasmesso quando il selectedItem_slot (ovvero lo slot sempre visibile) va aggiornato
signal selected_slot_update(slot: InvSlot)

@onready var inv: Inv = preload("res://inventory/player_inventory.tres")
@onready var slots: Array = $MarginContainer/HBoxContainer/MarginContainer/NinePatchRect/GridContainer.get_children()

@onready var selectedItem: InvItem = null
@onready var selectedItem_titleArea = $MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/TitleArea
@onready var selectedItem_imgArea = $MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer/CenterContainer/TextureRect/MarginContainer/Panel/Sprite2D
@onready var selectedItem_descrArea = $MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/DescriptionArea

var is_open = false
var selectedItem_index = 0



func _ready():
	for i in slots.size():
		slots[i].slot_index = i
		slots[i].slot_premuto.connect(manage_slot_selection)
	slots[selectedItem_index].select()
	inv.update.connect(update_slots)		#quando arriva il segnale update (da inventory) allora chiama la funzione update_slots()
	update_slots()
	close()


func update_slots():
	for i in range (min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])
		if(i == selectedItem_index):
			updateSelectedItem_info()
			selectedItem = inv.slots[i].item
			Global.emit_signal("selected_slot_update", inv.slots[i], i)

func manage_slot_selection(new_selection_index):
	slots[selectedItem_index].deselect()
	selectedItem_index = new_selection_index
	slots[selectedItem_index].select()
	updateSelectedItem_info()
	Global.emit_signal("selected_slot_update", inv.slots[selectedItem_index], selectedItem_index)


func updateSelectedItem_info():
	selectedItem = inv.slots[selectedItem_index].item
	if !selectedItem:
		selectedItem_titleArea.text = "Nothing"
		selectedItem_imgArea.visible = false
		selectedItem_descrArea.text = "Literally nothing."
	else:
		selectedItem_titleArea.text = selectedItem.title
		selectedItem_imgArea.visible = true
		selectedItem_imgArea.texture = selectedItem.texture
		selectedItem_descrArea.text = selectedItem.description
		#item_visual.visible = true
		#item_visual.texture = slot.item.texture


#in _process() "inventario" è il nome che ho dato all'azione quando premo i
func _process(_delta):
	if Input.is_action_just_pressed("inventario") and !GameState.in_dialogue:
		if is_open:
			close()
		else:
			open()


func open():
	visible = true
	is_open = true


func close():
	visible = false
	is_open = false
