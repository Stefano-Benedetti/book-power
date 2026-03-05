extends Control

var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		if Input.is_action_just_pressed("pause"):
			if is_open:
				close()
			else:
				open()

func open():
	visible = true
	is_open = true

func close():
	visible = false
	is_open = false

func _on_resume_pressed():
	close()
	
func _on_quit_pressed():
	get_tree().change_scene_to_file("res://menus/scenes/main_menu.tscn")
