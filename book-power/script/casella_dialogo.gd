extends Control

@onready var label = $PanelContainer/Label

var index = 0

var dialoghi_per_quest := {
	0: [
		"Hi, you seem new around here. I remember how hard the first year was, luckily I'm at the eigth year now! Computer Engineering is hard for sure.",
		"While you're here, could you do me a favor? I need 2 euros to get potato chips at the vending machine. You can steal 50 cents from each one of the old dudes wondering around the place.",
		"Watch out, they are very bad people and will try to demotivate you as soon as you get close to them. They will say very mean things to you that might push you to drop out the university at some point."
	],
	1: [
		"Thank you! Go up and then to the right, at the end of the road there is a gate I opened. ",
		"I will be there waiting for you, we have another problem to solve."
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
		GameState.in_dialogue = true
		Global.emit_signal("in_dialogo",true)
	else:
		_on_next_pressed()
		

func mostra_riga_corrente() -> void:
	var righe: Array = dialoghi_per_quest.get(QuestCounter.get_counter(),["..."])
	label.text = righe[index]

func _on_next_pressed() -> void:
	var righe: Array = dialoghi_per_quest.get(QuestCounter.get_counter(),["..."])
	if index < righe.size() - 1:
		index += 1
		mostra_riga_corrente()
	else:
		$".".hide()
		GameState.in_dialogue = false
		Global.emit_signal("in_dialogo",false)
