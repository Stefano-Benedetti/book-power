extends Node2D

@export var item_richiesto: InvItem

var qta_item_richiesti = 4

var quest_completata = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$npc_fuoricorso.update_quest.connect(quest_update)

func quest_update():
	if !quest_completata and $player.inv.countItem(item_richiesto) >= qta_item_richiesti:
		quest_completata = true
		QuestCounter.to_next_quest()
