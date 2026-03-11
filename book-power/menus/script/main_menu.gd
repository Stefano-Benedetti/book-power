extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/world.tscn")
	
func _on_logreg_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/scenes/login.tscn")

func _on_exit_pressed():
	get_tree().quit()

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://menus//scenes//settings_menu.tscn")
