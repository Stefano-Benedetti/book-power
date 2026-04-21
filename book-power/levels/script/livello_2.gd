extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Musica.gaming_music.play()
	
	# carico inventario player
	$player.inv.clean()
	for slot in Progress.inventory.slots:
		$player.inv.insert(slot.item)
	
	$player.current_dir = "right"
	Global.fixElSys.connect(circuiti_attivati)
	QuestCounter.quest_corrente = 2

func circuiti_attivati():
	QuestCounter.quest_corrente = 3


func _on_to_next_level_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		#se non si sta runnando game non passa al livello successivo
		if get_parent().name != "game":
			return
		
		#salvo il livello corrente nella classe dei progressi
		Progress.livello_corrente = 3
		
		#salvo inventario nella classe dei progressi
		Progress.inventory.clean()
		for slot in $player.inv.slots:
			Progress.inventory.insert(slot.item)
			
		#salvataggio dati
		var data = Global.getData()
		SaveSystem.save_data(data)
		
		Musica.stopMusic()
		
		get_parent().loadNextLevel()
