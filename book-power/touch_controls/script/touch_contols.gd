extends CanvasLayer

@onready var button_up = $up
@onready var button_down = $down
@onready var button_left = $left
@onready var button_right = $right
@onready var button_pick = $pick
@onready var button_inv = $inventory
@onready var button_pause = $pause
@onready var button_attack =$attack

func _ready() -> void:
	Global.in_dialogo.connect(set_dialogue_mode)
	Global.pick_update.connect(pickUpdate)
	button_pick.modulate = Color(0.6, 0.6, 0.6, 1)

func set_dialogue_mode(enabled: bool) -> void:
	# enabled = true => siamo in dialogo
	if enabled :
		button_up.hide()
		button_down.hide()
		button_left.hide()
		button_right.hide()
		button_attack.hide()
		button_pick.hide()
		button_inv.hide()
	else:
		button_up.show()
		button_down.show()
		button_left.show()
		button_right.show()
		button_attack.show()
		button_pick.show()
		button_inv.show()


func pickUpdate():
	if Global.pick_counter <= 0:
		if button_pick.modulate.a == 0.5:
			button_pick.modulate = Color(0.6, 0.6, 0.6, 0.5)
		if button_pick.modulate.a == 1:
			button_pick.modulate = Color(0.6, 0.6, 0.6, 1)
	else:
		button_pick.modulate = Color(1, 1, 1, 1.0)


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
	if Global.pick_counter > 0:
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

func _on_attack_pressed() -> void:
	button_attack.modulate.a = 0.5
func _on_attack_released() -> void:
	button_attack.modulate.a = 1
