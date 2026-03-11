extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$global_volume.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	$effects_volume.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	$music_volume.value = db_to_linear(AudioServer.get_bus_volume_db(2))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass	

func _on_back_pressed():
	get_tree().change_scene_to_file("res://menus/scenes/main_menu.tscn")

func _on_global_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0,linear_to_db($global_volume.value))


func _on_effects_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1,linear_to_db($effects_volume.value))


func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2,linear_to_db($music_volume.value))
