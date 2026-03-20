extends Node2D

@export var item_richiesto: InvItem

var MoneyTaken = false

var qta_item_richiesti = 4

var quest_completata = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$npc_fuoricorso.update_quest.connect(quest_update)
	$CanvasLayer2/casella_dialogo.fine_dialogo.connect(dropBook)
	$CanvasLayer2/casella_dialogo.fine_dialogo.connect(takeMoney)

func quest_update():
	if !quest_completata and $player.inv.countItem(item_richiesto) >= qta_item_richiesti:
		quest_completata = true
		QuestCounter.to_next_quest()

func dropBook():
	if QuestCounter.quest_corrente==0:
		$npc_fuoricorso.dropObject()

func takeMoney():
	if QuestCounter.quest_corrente==1 and !MoneyTaken :
		MoneyTaken = true
		$player.consumeItem(item_richiesto,4)
