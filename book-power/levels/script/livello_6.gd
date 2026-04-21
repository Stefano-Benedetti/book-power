extends Node2D

var esegui = true


func _ready() -> void:
	Global.fine_dialogo_player.connect(fine_livello)
	Musica.level6_music.play()
	$player.cam.global_position = $Node2D.global_position
	$player.make_sleep()
	QuestCounter.quest_corrente = 1000


func _process(delta: float) -> void:
	if esegui:
		sequenza_scena()
		esegui = false

func sequenza_scena():
	$player.move_camera() #avviene contemporaneamente alle altre cose
	await get_tree().create_timer(5).timeout
	$CanvasLayer/black_screen.appari(1)
	await get_tree().create_timer(1.5).timeout
	$player.make_sit()
	await get_tree().create_timer(1).timeout
	$CanvasLayer/black_screen.sparisci(1)
	
	await get_tree().create_timer(3).timeout
	
	Global.emit_signal("start_player_dialog")

func fine_livello():
	$CanvasLayer/black_screen.appari(1)
	await get_tree().create_timer(1.5).timeout
	Musica.stopMusic()
	get_parent().loadNextLevel()
