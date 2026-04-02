extends Node

signal save_succeeded
signal save_failed
signal load_succeeded(data)
signal load_failed

# Copy the URL from your bank.
var DATABASE_URL = "https://book-power-default-rtdb.europe-west1.firebasedatabase.app/"

var save_path = "user://data.save"

var never_loaded = true

func save_data(data: Dictionary):
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file.store_var(data):
		print("Data saved on local file.")
		if Auth.id_token.is_empty() or Auth.local_id.is_empty():
			save_succeeded.emit()
	else:
		print("Saving on local file failed.")
		
	if !Auth.id_token.is_empty() or !Auth.local_id.is_empty():
		# creating an URL
		var url = DATABASE_URL + "/users/" + Auth.local_id + ".json?auth=" + Auth.id_token

		_send_request(url, HTTPClient.METHOD_PUT, "save", JSON.stringify(data))


# Retrieves user data from the cloud or from local file.
func load_data():
	never_loaded = false
	if Auth.id_token.is_empty() or Auth.local_id.is_empty():
		if FileAccess.file_exists(save_path):
			var file = FileAccess.open(save_path,FileAccess.READ)
			var data = 0
			data = file.get_var(data)
			print("Data loaded from local file, user not logged in.")
			load_succeeded.emit(data)
			return
		else:
			print("Loading data failed both from cloud and from local file.")
			load_failed.emit()
			return
	
	var url = DATABASE_URL + "/users/" + Auth.local_id + ".json?auth=" + Auth.id_token
	
	_send_request(url, HTTPClient.METHOD_GET, "load")

func _send_request(url: String, method: HTTPClient.Method, request_type: String, body: String = "") -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	http_request.request_completed.connect(
		func(result, response_code, headers, response_body):
			_on_request_completed(result, response_code, headers, response_body, request_type, http_request)
	)
	
	var headers = ["Content-Type: application/json"]
	
	var error
	if method == HTTPClient.METHOD_PUT:
		error = http_request.request(url, headers, method, body)
	else: 
		error = http_request.request(url, headers, method)
	
	if error != OK:
		print("Error initiating a request: ", error)
		if request_type == "save":
			save_failed.emit()
		else:
			load_failed.emit()
		http_request.queue_free()

# Trasforma la risposta da bytes a testo
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, request_type: String, http_node: HTTPRequest) -> void:
	
	var json = JSON.new()
	var body_string = body.get_string_from_utf8()

	if body_string.is_empty() or body_string == "null":
		if request_type == "load":
			load_succeeded.emit({}) 
		http_node.queue_free()
		return
	
	var parse_error = json.parse(body_string)
	
	if parse_error != OK:
		print("JSON parse error: ", json.get_error_message())
		if request_type == "save":
			save_failed.emit()
		else:
			load_failed.emit()
		http_node.queue_free()
		return

	var response_data = json.get_data()
	
	# Se la risposta è un errore di firebase
	if response_data.has("error"):
		print("Firebase error: ", response_data["error"])
		if request_type == "save":
			save_failed.emit()
		else:
			load_failed.emit()
	
	# Se va tutto bene
	else:
		if request_type == "save":
			print("Data saved on cloud.")
			save_succeeded.emit()
		elif request_type == "load":
			print("Data loaded: ", response_data)
			load_succeeded.emit(response_data)
	
	http_node.queue_free()
