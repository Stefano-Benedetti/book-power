extends Node

@onready var livello_corrente: int = 0
@onready var inventory: Inv = preload("res://inventory/progress_inventory.tres")

func _ready() -> void:
	pass

func setInventory(inv_dictionary : Dictionary):
	var item_list = inv_dictionary.values()
	for item_name in item_list:
		inventory.insert(load("res://inventory/items/" + item_name + ".tres"))
