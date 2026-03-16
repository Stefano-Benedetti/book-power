extends Node

var current_scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.death.connect(stopMusic)
	get_tree().scene_changed.connect(changeMusic)
	
	# deve essere la prima canzone che inizia quando apri il gioco
	$menu_music.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func changeMusic() -> void:
	if get_tree().current_scene!=null  and  current_scene!=get_tree().current_scene.scene_file_path :
		current_scene = get_tree().current_scene.scene_file_path
		if current_scene == "res://menus/scenes/main_menu.tscn" or current_scene == "res://menus/scenes/settings_menu.tscn" or current_scene == "res://menus/scenes/login_menu.tscn":
			if !$menu_music.playing :
				# fermo qualsiasi canzone in riproduzione
				$gaming_music.stop()
				# avvio quella che mi serve
				$menu_music.play()
		if current_scene == "res://scenes/world.tscn":
			if !$gaming_music.playing :
				# fermo qualsiasi canzone in riproduzione
				$menu_music.stop()
				# avvio quella che mi serve
				$gaming_music.play()

func stopMusic() -> void:
	$gaming_music.stop()
