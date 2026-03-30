extends Control

var creds_save_path = "user://creds.save"

func _ready():
	Auth.registration_succeeded.connect(_on_registration_succeeded)
	Auth.registration_failed.connect(on_registration_failed)
	
	Auth.login_succeeded.connect(_on_login_succeeded)
	Auth.login_failed.connect(_on_login_failed)
	
	Auth.resetpass_succeeded.connect(_on_resetpass_succeeded)
	Auth.resetpass_failed.connect(_on_resetpass_failed)
	
	Auth.verification_succeeded.connect(_on_verification_succeeded)
	Auth.verification_failed.connect(_on_verification_failed)

	SaveSystem.load_succeeded.connect(_on_load_succeeded)
	SaveSystem.load_failed.connect(_on_load_failed)
	
	update_ui()
	
	if FileAccess.file_exists(creds_save_path) and Auth.is_logged_in():
		var file = FileAccess.open(creds_save_path,FileAccess.READ)
		var email = 0
		var password = 0
		$VBoxContainer/email.text = file.get_var(email)
		$VBoxContainer/password.text = file.get_var(password)
		$Label.text = "Logged in"


func _on_login_pressed():
	var email = $VBoxContainer/email.text
	var password = $VBoxContainer/password.text
	if email.is_empty() or password.is_empty():
		$Label.text = "Insert email and password."
		return
	$Label.text = "Loggin in..."
	$back.hide()
	Auth.login_user(email, password)

func _on_register_pressed():
	var email = $VBoxContainer/email.text
	var password = $VBoxContainer/password.text
	if email.is_empty() or password.is_empty():
		$Label.text = "Insert email and password."
		return
	$back.hide()
	$Label.text = "Registration in progress..."
	Auth.register_user(email, password)

func _on_resetpass_pressed() -> void:
	var email = $VBoxContainer/email.text
	Auth.reset_password(email)
	$Label.text = "Sending email..."

func _on_back_pressed():
	get_tree().change_scene_to_file("res://menus/scenes/main_menu.tscn")



func _on_registration_succeeded():
	$Label.text = "Registration succeeded!"
	
	var email = $VBoxContainer/email.text
	Auth.verify_email(email)

func on_registration_failed(error_message : String):
	$Label.text = "Registration failed: " + error_message
	$back.show()


func _on_resetpass_succeeded():
	$Label.text = "Password reset email sent, check your spelling or spam if you can't find it."
	
func _on_resetpass_failed(error_message : String):
	$Label.text = "Password reset failed: " + error_message


func _on_login_succeeded():
	$Label.text = "Login succeeded!"
	$DataChoice.show()

func _on_login_failed(error_message):
	$Label.text = "Login failed: " + error_message
	$back.show()
	
func _on_verification_succeeded():
	$Label.text = "Verification email sent, check your spelling or spam if you can't find it."
	Auth.logout()
	$back.show()
	
func _on_verification_failed(error_message):
	$Label.text = "Email verification failed: " + error_message
	$back.show()


func _on_load_succeeded(data: Dictionary):
	$Label.text = "Your data has been loaded."
	
	if !data.is_empty() :
		# Carico le impostazioni del volume
		AudioServer.set_bus_volume_db(0,linear_to_db(data.get("global_volume")))
		AudioServer.set_bus_volume_db(1,linear_to_db(data.get("effects_volume")))
		AudioServer.set_bus_volume_db(2,linear_to_db(data.get("music_volume")))
	$back.show()

func _on_load_failed():
	$Label.text = "Error loading data, try again."
	$back.show()


func _on_logout_pressed() -> void:
	var data = Global.getData()
	SaveSystem.save_data(data)
	DirAccess.remove_absolute(creds_save_path)
	Auth.logout()
	$VBoxContainer/email.text = ""
	$VBoxContainer/password.text = ""
	$Label.text = "Successfully logged out."
	update_ui()

func _on_remote_pressed():
	SaveSystem.load_data()
	var email = $VBoxContainer/email.text
	var password = $VBoxContainer/password.text
	var file = FileAccess.open(creds_save_path, FileAccess.WRITE)
	file.store_var(email)
	file.store_var(password)
	update_ui()
	
func _on_local_pressed():
	var data = Global.getData()
	SaveSystem.save_data(data)
	var email = $VBoxContainer/email.text
	var password = $VBoxContainer/password.text
	var file = FileAccess.open(creds_save_path, FileAccess.WRITE)
	file.store_var(email)
	file.store_var(password)
	update_ui()
	$back.show()

func update_ui():
	$DataChoice.hide()
	if Auth.is_logged_in():
		$HBoxContainer.hide()
		$resetpass.show()
		$logout.show()
	else:
		$resetpass.hide()
		$logout.hide()
		$HBoxContainer.show()
