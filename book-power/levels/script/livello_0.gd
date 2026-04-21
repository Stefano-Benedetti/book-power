extends Node2D

var esegui = true


func _ready() -> void:
	Musica.level0_music.play()
	$player.cam.global_position = $Node2D.global_position
	$player.make_sit()


func _process(delta: float) -> void:
	if esegui:
		sequenza_scena()
		esegui = false

func sequenza_scena():
	$player.move_camera() #avviene contemporaneamente alle altre cose
	await get_tree().create_timer(5).timeout
	$CanvasLayer/black_screen.appari(1)
	await get_tree().create_timer(1.5).timeout
	$player.make_sleep()
	await get_tree().create_timer(1).timeout
	$CanvasLayer/black_screen.sparisci(1)
	
	await get_tree().create_timer(3).timeout
	$player.zoom_camera_on_player()
	$CanvasLayer/black_screen.appari(0.3)
	Musica.stopMusic()
	await get_tree().create_timer(0.5).timeout
	get_parent().loadNextLevel()
