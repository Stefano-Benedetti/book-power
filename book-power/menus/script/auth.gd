extends Node

signal registration_succeeded(local_id)
signal registration_failed(error_message)

signal login_succeeded(local_id, id_token)
signal login_failed(error_message)

signal resetpass_succeeded
signal resetpass_failed

signal verification_succeeded
signal verification_failed

# This variable will store our API key after we read it from the file.
var FIREBASE_API_KEY: String = ""

# id_token is the temporary key that proves we are logged in.
# local_id is the user's permanent ID in Firebase.
var id_token: String = ""
var local_id: String = ""

func _ready():
	_load_api_key()

# This function loads our secret key from the 'secrets.cfg' file.
# This is a security practice to avoid exposing the key on GitHub.
func _load_api_key():
	var config = ConfigFile.new()
	var err = config.load("res://secrets.cfg")
	
	if err != OK:
		print("ERROR: The 'secrets.cfg' file could not be loaded.")
		print("Make sure the file exists and has your [firebase] api_key.")
	else:
		FIREBASE_API_KEY = config.get_value("firebase", "api_key", "")
		if FIREBASE_API_KEY.is_empty():
			print("ERROR: 'api_key' not found within [firebase] in 'secrets.cfg'")

# The login screen will call this function to register a user.
func register_user(email, password):
	# If the API key hasn't been loaded, we stop here.
	if FIREBASE_API_KEY.is_empty():
		print("API key not loaded. Check 'secrets.cfg'.")
		return

	# This is the Firebase endpoint (URL) for creating accounts.
	var url = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=" + FIREBASE_API_KEY
	
	# This is the data that Firebase expects (email, password).
	var body = {
		"email": email,
		"password": password
	}

	_send_request(url, body, "register")

# The login screen will call this function to log in a user.
func login_user(email, password):
	if FIREBASE_API_KEY.is_empty():
		print("API key not loaded. Check 'secrets.cfg'.")
		return

	# The login endpoint is different (signInWithPassword).
	var url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=" + FIREBASE_API_KEY
	var body = {
		"email": email,
		"password": password,
		"returnSecureToken": true
	}
	_send_request(url, body, "login")
	
func reset_password(email):
	if FIREBASE_API_KEY.is_empty():
		print("API key not loaded. Check 'secrets.cfg'.")
		return

	# The oob code endpoint is different (sendOobCode).
	var url = "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=" + FIREBASE_API_KEY
	var body = {
		"requestType": "PASSWORD_RESET",
		"email": email,
		"userIp": "0.0.0.0"
		}
	_send_request(url, body, "resetpass")
	
func verify_email(email):
	if FIREBASE_API_KEY.is_empty():
		print("API key not loaded. Check 'secrets.cfg'.")
		return

	# The oob code endpoint is different (sendOobCode).
	var url = "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=" + FIREBASE_API_KEY
	var body = {
		"requestType": "VERIFY_EMAIL",
		"email": email,
		"idToken": id_token
		}
	_send_request(url, body, "verification")
	
func logout():
	id_token = ""
	local_id = ""
	print("User successfully logged out.")

func _send_request(url: String, body: Dictionary, request_type: String) -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	http_request.request_completed.connect(
		func(result, response_code, headers, response_body):
		
			_on_request_completed(result, response_code, headers, response_body, request_type, http_request)
	)

	var headers = ["Content-Type: application/json"]
	
	var body_string = JSON.stringify(body)

	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body_string)
	
	if error != OK:
		print("Error starting the request: ", error)
		http_request.queue_free()

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, request_type: String, http_node: HTTPRequest) -> void:
	
	var json = JSON.new()
	
	var body_string = body.get_string_from_utf8()
	
	var parse_error = json.parse(body_string)
	if parse_error != OK:
		print("JSON parse error: ", json.get_error_message())
		if request_type == "register":
			registration_failed.emit("Invalid server response.")
		elif request_type == "login":
			login_failed.emit("Invalid server response.")
		elif request_type == "resetpass":
			resetpass_failed.emit("Invalid server response.")
		else :
			verification_failed.emit("Invalid server response.")
		http_node.queue_free()
		return
		
	var response_data = json.get_data()

	if response_data.has("error"):
		var error_code = response_data["error"]["message"]
		print("Firebase error (code): ", error_code)

		var translated_message = _translate_firebase_error(error_code)
		if request_type == "register":
			registration_failed.emit(translated_message)
		elif request_type == "login":
			login_failed.emit(translated_message)
		elif request_type == "resetpass":
			resetpass_failed.emit(translated_message)
		else :
			verification_failed.emit(translated_message)
	
	elif response_data.has("idToken"):
		id_token = response_data["idToken"]
		local_id = response_data["localId"]
		print("Sucess! Type: ", request_type, " | User ID: ", local_id)
		
		if request_type == "register":
			registration_succeeded.emit()
		else:
			login_succeeded.emit()
	elif response_data.has("email") and request_type=="resetpass":
		print("Success! Email sent to ",response_data.get("email"))
		resetpass_succeeded.emit()
	elif response_data.has("email") and request_type=="verification":
		print("Success! Email sent to ",response_data.get("email"))
		verification_succeeded.emit()
		
	else:
		# If the response contains neither "error" nor "idToken".
		print("Unknown response from Firebase: ", response_data)
		if request_type == "register":
			registration_failed.emit("Unknown error.")
		elif request_type == "login":
			login_failed.emit("Unknown error.")
		elif request_type == "resetpass":
			resetpass_failed.emit("Unknown error.")
		else :
			verification_failed.emit("Unknown error.")
	http_node.queue_free()

func _translate_firebase_error(error_code: String) -> String:
	match error_code:
		"EMAIL_EXISTS":
			return "this email is already in use."
		"EMAIL_NOT_FOUND":
			return "email not found."
		"INVALID_LOGIN_CREDENTIALS":
			return "incorrect password."
		"WEAK_PASSWORD":
			return "password too short (must be at least 6 characters)."
		"INVALID_EMAIL":
			return "invalid email."
		"MISSING_PASSWORD":
			return "password is empty."
		"MISSING_EMAIL":
			return "email is empty."
		_:
			return "Error: (" + error_code + ")"

func is_logged_in():
	return id_token != "" and local_id != ""
