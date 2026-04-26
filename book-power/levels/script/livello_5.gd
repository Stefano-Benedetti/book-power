extends Node2D


func _ready() -> void:
	Global.fine_dialogo.connect(startBossFight)
	Global.morte_fuoricorso.connect(bossDeath)
	
	Musica.boss_music.play()
	
	QuestCounter.quest_corrente = 9


func bossDeath():
	pass

func startBossFight():
	$npc_fuoricorso.fighting = true
