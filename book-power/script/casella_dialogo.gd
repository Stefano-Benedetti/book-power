extends Control

@onready var label = $PanelContainer/Label

var index = 0

var whos_talking

var dialoghi_robot := {
	5: [
		"THANK YOU, HUMAN. YOU FIXED ME. I BECAME UNSTABLE AFTER AN INCOMPETENT STUDENT TRIED TO ''IMPROVE'' ME. HE LOOKED FRIENDLY BUT HE'S EVIL. TAKE THIS BOOK AS A GIFT, YOU DESERVE IT."
	]
}

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
		"Hi again, the police was here a few minutes ago as you could see from the roadblock... that's probably because someone passed through here and broke a house's electrical system.",
		"The house I'm talking about is a very big house and you will find it going down this road. On one of its walls there is an access panel for its electrical system.",
		"I think we should get to the bottom of this, but we need to get past the barrier, located next to the house, and the only way to open it, is to fix the house's electrical system. After that, you will be able to pull a lever and open the barrier.",
		"However, nobody knows how to fix it: someone, probably one of the old men, stole the book containing the knowledge needed to understand electronic circuits. You should go and retrieve the book, then you could use it on the access panel."
	],
	3: [
		"Good job! I will be waiting for you on the other side of the barrier. Remember you also need to pull the lever in front of the barrier."
	],
	4: [
		"I think I found who did all that mess! There's a robot blocking the road and it pushes back and hurts anyone who tries to go past him.",
		"We should find a way to disable it, or at least to calm it down, however I don't know how to do that. I only know that you need to use a computer connected to the robot, it should be next to the robot. Try to find a book with the necessary knowledge to use that computer.",
		"There's a closed chest somewhere, maybe you can find something useful in it, but you need a key to open it. I actually had found a key, but I lost it on the way here. I probably dropped it on the ground. Woops."
	],
	5: [
		"Looks like you fixed the robot, good job! Now we should continue and check if he did any more damage."
	]
}

func _ready() -> void:
	# finché nessuno mi parla deve rimanere nascosto
	hide()
	Global.start_dialog.connect(avvia_dialogo_quest)
	Global.start_robot_dialog.connect(avvia_dialogo_robot)
	
	
func avvia_dialogo_robot():
	whos_talking = "robot"
	avvia_dialogo_quest()

func avvia_dialogo_quest() -> void:
	if !visible:
		index = 0
		show()
		mostra_riga_corrente()
		GameState.in_dialogue = true
		Global.emit_signal("in_dialogo",true)
	else:
		_on_next_pressed()


func mostra_riga_corrente() -> void:
	var righe: Array
	if whos_talking == "robot":
		righe = dialoghi_robot.get(QuestCounter.get_counter(),["..."])
	else :
		#parla npc fuoricorso
		righe = dialoghi_per_quest.get(QuestCounter.get_counter(),["..."])
	label.text = righe[index]

func _on_next_pressed() -> void:
	var righe: Array
	if whos_talking == "robot":
		righe = dialoghi_robot.get(QuestCounter.get_counter(),["..."])
	else:
		#parla npc fuoricorso
		righe = dialoghi_per_quest.get(QuestCounter.get_counter(),["..."])
		
	if index < righe.size() - 1:
		# mostra riga successiva
		index += 1
		mostra_riga_corrente()
	else:
		hide()
		GameState.in_dialogue = false            #per sbloccare l'input
		Global.emit_signal("in_dialogo",false)   #per mostrare gli altri tasti
		Global.emit_signal("fine_dialogo")
		if whos_talking == "robot":
			Global.emit_signal("fine_dialogo_robot")
		whos_talking = ""
