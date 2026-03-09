extends Control

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.death.connect(open)
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func open():
	get_tree().paused = true
	show()
	
func _on_ok_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menus/scenes/main_menu.tscn")
	
