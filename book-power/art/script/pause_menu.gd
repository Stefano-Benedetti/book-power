extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		if Input.is_action_just_pressed("pause"):
			if get_tree().paused:
				close()
			else:
				open()

func open():
	get_tree().paused = true
	show()

func close():
	hide()
	get_tree().paused = false

func _on_resume_pressed():
	close()
	
func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menus/scenes/main_menu.tscn")
	
