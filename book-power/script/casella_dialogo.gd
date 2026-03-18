extends Control

@onready var label = $PanelContainer/MarginContainer/Label

var index = 0

var quest_corrente = 0

var dialoghi_per_quest := {
	0: [
		"Ciao avventuriero!",
		"Puoi raccogliere 3 mele per me?"
	],
	1: [
		"Grazie per le mele!",
		"Ora portale al cuoco in città."
	],
	2: [
		"Ottimo lavoro!",
		"Ci vediamo al prossimo livello."
	]
}

func _ready() -> void:
	avvia_dialogo_quest(quest_corrente)

func avvia_dialogo_quest(quest_stage: int) -> void:
	quest_corrente = quest_stage
	index = 0
	$PanelContainer.show()
	mostra_riga_corrente()

func mostra_riga_corrente() -> void:
	var righe: Array = dialoghi_per_quest.get(quest_corrente,["..."])
	label.text = righe[index]

func _on_next_pressed() -> void:
	var righe: Array = dialoghi_per_quest.get(quest_corrente,["..."])
	if index < righe.size() - 1:
		index += 1
		mostra_riga_corrente()
	else:
		$PanelContainer.hide()


func _on_next_quest_pressed() -> void:
	quest_corrente += 1
	avvia_dialogo_quest(quest_corrente)
