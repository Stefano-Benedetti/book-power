extends Control

var disabled = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.death.connect(disable)
	$Panel.hide()
	$Panel2.hide()
	$Panel2/settings_submenu/global_volume.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	$Panel2/settings_submenu/effects_volume.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	$Panel2/settings_submenu/music_volume.value = db_to_linear(AudioServer.get_bus_volume_db(2))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("pause") and !disabled:
		if get_tree().paused:
			close()
		else:
			open()
	# impostazioni-->pausa quando premi esc
	if Input.is_action_just_pressed("pause") and $Panel2.visible :
		_on_back_pressed()
		
func open():
	get_tree().paused = true
	$Panel.show()

func close():
	$Panel.hide()
	get_tree().paused = false
	
func disable():
	disabled = true
func enable():
	disabled = false

func _on_resume_pressed():
	close()
	
func _on_quit_pressed():
	get_tree().paused = false
	Musica.stopMusic()
	get_tree().change_scene_to_file("res://menus/scenes/main_menu.tscn")
	


func _on_settings_pressed() -> void:
	$Panel.hide()
	$Panel2.show()
	disable()
	


func _on_global_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0,linear_to_db($Panel2/settings_submenu/global_volume.value))


func _on_effects_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1,linear_to_db($Panel2/settings_submenu/effects_volume.value))


func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2,linear_to_db($Panel2/settings_submenu/music_volume.value))


func _on_back_pressed() -> void:
	enable()
	$Panel2.hide()
	$Panel.show()


func _on_texture_button_button_up() -> void:
	$tutorial_screen.show()
