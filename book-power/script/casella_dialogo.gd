extends Control

@onready var label = $PanelContainer/Label

var index = 0

signal fine_dialogo

var dialoghi_per_quest := {
	0: [
		"Hi, you seem new around here. I remember how hard the first year was, luckily I'm at my eigth year now! Computer Engineering is hard for sure.",
		"While you're here, could you do me a favor? I need 2 euros to get potato chips at the vending machine. You can steal 50 cents from each one of the old dudes wondering around the place.",
		"Watch out, they are very bad people and will try to demotivate you as soon as you get close to them. They will say very mean things to you that will eventually push you to drop out of university.",
		"Take this book, this will help you in studying and keeping your motivation. Good luck!"
	],
	1: [
		"Thank you! You are very good at this, many students would have already dropped out. Now go up and then to the right, past the road block, the police removed it just now.",
		"I will be there, waiting for you. We have another problem to solve."
	],
	2: [
		"Hi again, the police was here a few minutes ago as you could see from the roadblock... that's probably because someone passed through here and broke that house's electrical system, the one down this road.",
		"I think we should get to the bottom of this, but we need to get past the barrier and the only way to open it, is to fix the house's electrical system.",
		"However, nobody knows how to fix it: someone, probably one of the old men, stole the book containing the knowledge needed to understand electronic circuits. You should go and retrieve the book, then you could use it and fix the electrical system."
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
		fine_dialogo.emit()
