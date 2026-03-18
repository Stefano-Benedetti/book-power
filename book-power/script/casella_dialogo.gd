extends Control

@onready var label = $PanelContainer/MarginContainer/Label

var index = 0

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
	# finché nessuno mi parla deve rimanere nascosto
	$".".hide()
	Global.start_dialog.connect(avvia_dialogo_quest)
	

func avvia_dialogo_quest() -> void:
	if !$".".visible:
		index = 0
		$".".show()
		mostra_riga_corrente()
	else:
		_on_next_pressed()
		

func mostra_riga_corrente() -> void:
	var righe: Array = dialoghi_per_quest.get(QuestCounter.get_counter(),["..."])
	label.text = righe[index]

func _on_next_pressed() -> void:
	print("godo")
	var righe: Array = dialoghi_per_quest.get(QuestCounter.get_counter(),["..."])
	if index < righe.size() - 1:
		index += 1
		mostra_riga_corrente()
	else:
		$".".hide()
