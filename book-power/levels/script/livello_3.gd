extends Node2D


func _ready() -> void:
	QuestCounter.quest_corrente = 4
	Global.sbloccaRobot.connect(robotCurato)

func _on_to_next_level_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		#se non si sta runnando game non passa al livello successivo
		if get_parent().name != "game":
			return
		Progress.livello_corrente = 3		#salvo il livello corrente nella classe dei progressi
		Progress.inventory = $player.inv	#salvo inventario nella classe dei progressi
		get_parent().loadNextLevel()

func robotCurato():
	QuestCounter.quest_corrente = 5
