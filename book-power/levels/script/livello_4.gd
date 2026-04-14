extends Node2D

var talked_with_computer = false

func _ready() -> void:
	Global.fine_dialogo_computer.connect(talkedWithComputer)
	$player.current_dir = "down"
	QuestCounter.quest_corrente = 6
	$CanvasLayer2/counter.hide()

func talkedWithComputer():
	if not talked_with_computer:
		talked_with_computer = true
		$CanvasLayer2/counter.show()

func _on_to_next_level_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		#se non si sta runnando game non passa al livello successivo
		if get_parent().name != "game":
			return
		Progress.livello_corrente = 5		#salvo il livello corrente nella classe dei progressi
		Progress.inventory = $player.inv	#salvo inventario nella classe dei progressi
		get_parent().loadNextLevel()
