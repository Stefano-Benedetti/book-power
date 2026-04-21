extends Node2D


func _ready() -> void:
	Musica.gaming_music.play()
	# carico inventario player
	$player.inv.clean()
	for slot in Progress.inventory.slots:
		$player.inv.insert(slot.item)
	
	$player.current_dir = "up"
	
	QuestCounter.quest_corrente = 4
	Global.sbloccaRobot.connect(robotCurato)

func _on_to_next_level_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		#se non si sta runnando game non passa al livello successivo
		if get_parent().name != "game":
			return
		
		#salvo il livello corrente nella classe dei progressi
		Progress.livello_corrente = 4
		
		#salvo inventario nella classe dei progressi
		Progress.inventory.clean()
		for slot in $player.inv.slots:
			Progress.inventory.insert(slot.item)
		
		#salvataggio dati
		var data = Global.getData()
		SaveSystem.save_data(data)
		
		get_parent().loadNextLevel()

func robotCurato():
	QuestCounter.quest_corrente = 5
