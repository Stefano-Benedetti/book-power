extends Node

var current_scene

@onready var menu_music = $menu_music
@onready var gaming_music = $gaming_music
@onready var level0_music = $level0_music
@onready var level6_music = $level6_music
@onready var boss_music = $boss_music
@onready var credits_music = $credits_music


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.death.connect(stopMusic)
	#get_tree().scene_changed.connect(changeMusic)

#func changeMusic() -> void:
	#if get_tree().current_scene!=null  and  current_scene!=get_tree().current_scene.scene_file_path :
		#current_scene = get_tree().current_scene.scene_file_path
		#if current_scene == "res://menus/scenes/main_menu.tscn" or current_scene == "res://menus/scenes/settings_menu.tscn" or current_scene == "res://menus/scenes/login_menu.tscn":
			#if !$menu_music.playing :
				## fermo qualsiasi canzone in riproduzione
				#stopMusic()
				## avvio quella che mi serve
				#$menu_music.play()
		#if  current_scene == "res://scenes/livello_1" or current_scene == "res://scenes/livello_2" or current_scene == "res://scenes/livello_3" or current_scene == "res://scenes/livello_4":
			#if !$gaming_music.playing :
				## fermo qualsiasi canzone in riproduzione
				#stopMusic()
				## avvio quella che mi serve
				#$gaming_music.play()
		#if current_scene == "res://scenes/livello_0":
			#if !$level0_music.playing:
				#stopMusic()
				#$level0_music.play()
		#if current_scene == "res://scenes/livello_6":
			#if !$level6_music.playing:
				#stopMusic()
				#$level6_music.play()


func stopMusic() -> void:
	$menu_music.stop()
	$level0_music.stop()
	$level6_music.stop()
	$gaming_music.stop()
