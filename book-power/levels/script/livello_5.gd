extends Node2D


func _ready() -> void:
	Global.fine_dialogo.connect(startBossFight)
	Global.morte_fuoricorso.connect(bossDeath)
	Global.fine_dialogo.connect(levelEnd)
	
	QuestCounter.quest_corrente = 9

func _process(delta: float) -> void:
	if GameState.in_dialogue and Input.is_action_just_pressed("Pick_object"):
		Global.emit_signal("start_dialog")
		
	#DA TOGLIERE!!!!! E' SOLO PER DEBUGGING!!!!!!!
	if Input.is_action_just_pressed("attacca"):
		$npc_fuoricorso.current_health = 0
	#---------------------------------------------

func startBossFight():
	if $npc_fuoricorso:
		Musica.boss_music.play()
		$npc_fuoricorso.set_on_fightmode()

func bossDeath():
	QuestCounter.quest_corrente = 10
	Global.emit_signal("start_dialog")

func levelEnd():
	if QuestCounter.quest_corrente == 10:
		#se non si sta runnando game non passa al livello successivo
		if get_parent().name != "game":
			return
		
		#salvo il livello corrente nella classe dei progressi
		Progress.livello_corrente = 6
		
		#salvo inventario nella classe dei progressi
		Progress.inventory.clean()
		for slot in $player.inv.slots:
			Progress.inventory.insert(slot.item)
		
		#salvataggio dati
		var data = Global.getData()
		SaveSystem.save_data(data)
		
		Musica.stopMusic()
		
		$CanvasLayer3/black_screen.appari(2)
		await get_tree().create_timer(2.5).timeout
		
		get_parent().loadNextLevel()
