extends Node2D

var esegui = true


func _ready() -> void:
	$player.cam.global_position = $Node2D.global_position
	$player.make_sitted()


func _process(delta: float) -> void:
	if esegui:
		sequenza_scena()
		esegui = false

func sequenza_scena():
	$player.move_camera() #avviene contemporaneamente alle altre cose
	await get_tree().create_timer(5).timeout
	$CanvasLayer/black_screen.appari()
	await get_tree().create_timer(1.5).timeout
	$player.make_sleep()
	await get_tree().create_timer(1).timeout
	$CanvasLayer/black_screen.sparisci()
