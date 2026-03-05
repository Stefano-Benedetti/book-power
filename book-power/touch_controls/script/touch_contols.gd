extends CanvasLayer

@onready var button_up = $up
@onready var button_down = $down
@onready var button_left = $left
@onready var button_right = $right
@onready var button_pick = $pick
@onready var button_inv = $inventory
@onready var button_pause = $pause


func _on_up_pressed() -> void:
	button_up.modulate.a = 0.5
func _on_up_released() -> void:
	button_up.modulate.a = 1


func _on_down_pressed() -> void:
	button_down.modulate.a = 0.5
func _on_down_released() -> void:
	button_down.modulate.a = 1


func _on_left_pressed() -> void:
	button_left.modulate.a = 0.5
func _on_left_released() -> void:
	button_left.modulate.a = 1


func _on_right_pressed() -> void:
	button_right.modulate.a = 0.5
func _on_right_released() -> void:
	button_right.modulate.a = 1


func _on_pick_pressed() -> void:
	button_pick.modulate.a = 0.5
func _on_pick_released() -> void:
	button_pick.modulate.a = 1


func _on_inventory_pressed() -> void:
	button_inv.modulate.a = 0.5
func _on_inventory_released() -> void:
	button_inv.modulate.a = 1

func _on_pause_pressed() -> void:
	button_pause.modulate.a = 0.5
func _on_pause_released() -> void:
	button_pause.modulate.a = 1
