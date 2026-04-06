extends Control

var _save_done := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ConfirmNewgame.hide()
	$Control/HBoxContainer.hide()
	$Control/logreg.hide()
	$Control/settings.hide()
	
	SaveSystem.save_succeeded.connect(_on_save_end)
	SaveSystem.save_failed.connect(_on_save_end)
	
	SaveSystem.load_succeeded.connect(_on_load_succeeded)
	SaveSystem.load_failed.connect(_on_load_failed)
	
	Auth.login_succeeded.connect(_on_login_succeeded)
	Auth.login_failed.connect(_on_login_failed)
	
	if SaveSystem.never_loaded:
		autologin()
	
	else:
		#$Label.text = "Logged in."
		show_buttons()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	
func _on_logreg_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/scenes/login.tscn")

# occhio: se non aspetta la fine di save_data, poi esegue get_tree.quit() senza salvare
func _on_exit_pressed():
	var data = Global.getData()
	# Connetti una sola volta save_succeded/failed a _on_save_end
	#SaveSystem.save_succeeded.connect(_on_save_end, CONNECT_ONE_SHOT)
	#SaveSystem.save_failed.connect(_on_save_end, CONNECT_ONE_SHOT)
	
	_save_done = false
	SaveSystem.save_data(data)

	# Aspetta finché non arriva success/fail del salvataggio
	while not _save_done:
		await get_tree().process_frame
		
	# poi esce
	get_tree().quit()

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://menus//scenes//settings_menu.tscn")

func _on_save_end() -> void:
	_save_done = true

func autologin():
	var path = "user://creds.save"
	
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path,FileAccess.READ)
		var email = 0
		var password = 0
		email = file.get_var(email)
		password = file.get_var(password)
		Auth.login_user(email, password)
	else:
		$Label.text = "NOT logged in, your data will be saved locally."
		SaveSystem.load_data()


func _on_login_succeeded():
	$Label.text = "Successfully logged in."
	SaveSystem.load_data()
func _on_login_failed(message: String):
	print(message)
	$Label.text = "LOGIN FAILED, your data will be saved locally."
	SaveSystem.load_data()
	
func _on_load_succeeded(data: Dictionary):
	
	if !data.is_empty() :
		# Carico le impostazioni del volume
		AudioServer.set_bus_volume_db(0,linear_to_db(data.get("global_volume")))
		AudioServer.set_bus_volume_db(1,linear_to_db(data.get("effects_volume")))
		AudioServer.set_bus_volume_db(2,linear_to_db(data.get("music_volume")))
		Progress.livello_corrente = data.get("current_level")
		##TO FIX Progress.inventory = data.get("inventory")
	$Label.text = "Your data has been loaded."
	show_buttons()
	
func _on_load_failed():
	print("Error loading data.")
	$Label.text = "Error loading data."
	show_buttons()

func show_buttons():
	$Control/HBoxContainer.show()
	$Control/logreg.show()
	$Control/settings.show()


func _on_newgame_pressed() -> void:
	$ConfirmNewgame.show()


func _on_yes_pressed() -> void:
	DirAccess.remove_absolute("user://data.save")
	$Label.text = "New game loaded, old game was deleted."
	Progress.livello_corrente = 1
	##TO FIX Progress.inventory = 0
	var data = Global.getData()
	SaveSystem.save_data(data)
	$ConfirmNewgame.hide()


func _on_no_pressed() -> void:
	$ConfirmNewgame.hide()
