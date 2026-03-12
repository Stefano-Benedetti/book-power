extends Control

func _ready():
	pass

func _on_login_pressed():
	var email = $VBoxContainer/email.text
	var password = $VBoxContainer/password.text
	

func _on_register_pressed():
	var email = $VBoxContainer/email.text
	var password = $VBoxContainer/password.text
	
func _on_back_pressed():
	get_tree().change_scene_to_file("res://menus/scenes/main_menu.tscn")

func _on_FirebaseAuth_login_succeeded():
	
	$Label.text = "Login succeeded!"

func on_login_failed(error_code, message):
	print("error code: " + str(error_code))
	print("message: " + str(message))
	if str(message) == "INVALID_LOGIN_CREDENTIALS" :
		$Label.text = "Wrong password!"
	elif str(message) == "MISSING_PASSWORD" or str(message) == "WEAK_PASSWORD : Password should be at least 6 characters" :
		$Label.text = "Password should be at least 6 characters!"
	elif str(message) == "MISSING_EMAIL" or str(message) == "INVALID_EMAIL":
		$Label.text = "Invalid email!"
	else :
		$Label.text = "Login failed: "+str(message)

func on_signup_failed(error_code, message):
	print("error code: " + str(error_code))
	print("message: " + str(message))
	if str(message) == "EMAIL_EXISTS" :
		$Label.text = "This account already exists!"
	elif str(message) == "MISSING_PASSWORD" or str(message) == "WEAK_PASSWORD : Password should be at least 6 characters" :
		$Label.text = "Password should be at least 6 characters!"
	elif str(message) == "MISSING_EMAIL" or str(message) == "INVALID_EMAIL":
		$Label.text = "Invalid email!"
	else :
		$Label.text = "Registration failed: "+str(message)
