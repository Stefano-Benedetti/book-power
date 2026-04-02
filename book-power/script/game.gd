extends Node2D

@export var livello_partenza: int = 1
@onready var livelli: Array
@onready var livello_corrente: PackedScene = null
@onready var scena_liv_corrente: Node = null
var indice_livello: int = 0

func _ready() -> void:
	livello_partenza = Progress.livello_corrente
	livelli = [
		preload("res://levels/scenes/livello_1.tscn"),
		preload("res://levels/scenes/livello_2.tscn")
	]
	loadLevel(livello_partenza-1) # carica il primo livello (indice 0)


func loadLevel(indice: int) -> void:
	$loading_screen.show()
	await get_tree().create_timer(0.1).timeout #da il tempo a godot di renderizzare il loading screen
	
	get_tree().paused = true
	
	if scena_liv_corrente:
		scena_liv_corrente.queue_free()
		scena_liv_corrente = null
		livello_corrente = null
	
	if indice >= 0 and indice < livelli.size():
		indice_livello = indice
		livello_corrente = livelli[indice_livello]
		scena_liv_corrente = livello_corrente.instantiate()
		add_child(scena_liv_corrente)
		
		await get_tree().process_frame	# Aspetta il frame successivo per assicurarsi che tutto sia inizializzato
	
	$loading_screen.hide()
	get_tree().paused = false


func loadNextLevel() -> void:
	var prossimo_indice = indice_livello + 1
	if prossimo_indice >= livelli.size():
		return
	loadLevel(prossimo_indice)
