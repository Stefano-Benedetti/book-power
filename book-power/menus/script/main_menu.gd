extends Control

var _save_done := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/world.tscn")
	
func _on_logreg_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/scenes/login.tscn")

# occhio: se non aspetta la fine di save_data, poi esegue get_tree.quit() senza salvare
func _on_exit_pressed():
	var data = {
		"global_volume" = db_to_linear(AudioServer.get_bus_volume_db(0)),
		"effects_volume" = db_to_linear(AudioServer.get_bus_volume_db(1)),
		"music_volume" = db_to_linear(AudioServer.get_bus_volume_db(2))
	}
	# Connetti una sola volta save_succeded/failed a _on_save_end
	SaveSystem.save_succeeded.connect(_on_save_end, CONNECT_ONE_SHOT)
	SaveSystem.save_failed.connect(_on_save_end, CONNECT_ONE_SHOT)

	SaveSystem.save_data(data)

	# Aspetta finché non arriva success/fail del salvataggio, ma con timeout
	var timer := get_tree().create_timer(5.0)
	while not _save_done and timer.time_left > 0.0:
		await get_tree().process_frame
		
	# poi esce
	get_tree().quit()

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://menus//scenes//settings_menu.tscn")

func _on_save_end() -> void:
	_save_done = true
