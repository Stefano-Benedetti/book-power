extends Control

@onready var label = $PanelContainer/Label

var index = 0

var whos_talking

var dialoghi_player := {
	1000: [
			"Uhh... it was all just a dream? Oh no, I slept all night and the exam starts in four hours, I better get back to work..."
		]
}

var dialoghi_computer := {
	6: [
		"Hello stranger, can you help me to connect to my computer friends? Some crazy robot turned them all off and while I managed to escape, I don't have any hands to press their power buttons!",
		"You might have noticed a firewall that blocks the road ahead, if you help me I will disable it and let you continue on your journey.",
		"Turn them all on for now, then come back and I will give you further instructions."
	],
	7: [
		"Nice! But it is not over yet, we are still unable to communicate: I need you to return us our access point, I saw the robot bringing it into a cave. Be careful, caves are filled with angry bats around these parts.",
		"Once you have the access point, place it on that white platform, then everyone will automatically connect to it."
	],
	8: [
		"Sending ARP requests...",
		"Yes! I can see all of them now! Thank you, whoever you are!",
		"The firewall is now disabled, but wait, I have a present for you: take this book, as a reward for your kindness."
	]
}

var dialoghi_robot := {
	5: [
		"THANK YOU, HUMAN. YOU FIXED ME. I BECAME UNSTABLE AFTER AN INCOMPETENT STUDENT TRIED TO ''IMPROVE'' ME. HE LOOKS FRIENDLY BUT HE IS NOT TO BE TRUSTED.",
		"I SEE YOU USED A BOOK TO FIX ME, GIVE IT TO ME. I WANT TO LEARN HOW TO IMPROVE MYSELF WITHOUT RELYING ON OTHERS. I HAVE ANOTHER BOOK I CAN GIVE YOU IN RETURN."
	]
}

var dialoghi_per_quest := {
	0: [
		"Hi, you seem new around here. I remember how hard the first year was, luckily I'm at my eigth year now! Computer Engineering is hard for sure.",
		"While you're here, would you do me a favor? I need 2 euros to get potato chips at the vending machine. You can steal 50 cents from each one of the old dudes wandering around the place.",
		"Watch out, they are very bad people and will try to demotivate you as soon as you get close to them. They will say very mean things to you that will eventually push you to drop out of university.",
		"Take this book, it will help you in studying and keeping your motivation. Good luck!"
	],
	1: [
		"Thank you! You are very good at this, many students would have already dropped out. Now go up and then to the right, past the road block, the police removed it just now.",
		"I will be there, waiting for you. We have another problem to solve."
	],
	2: [
		"Hi again, the police was here a few minutes ago as you could see from the roadblock... that's probably because someone passed through here and broke a house's electrical system.",
		"The house I'm talking about is a very big house and you will find it going down this road. On one of its walls there is an access panel for its electrical system.",
		"I think we should get to the bottom of this, but we need to get past the barrier, located next to the house, and the only way to open it, is to fix the house's electrical system. After that, you will be able to pull a lever and open the barrier.",
		"However, nobody knows how to fix it: someone, probably one of the old men, stole the book containing the knowledge needed to understand electronic circuits. You should retrieve the book, then you can use it to fix the access panel."
	],
	3: [
		"Good job! I will be waiting for you on the other side of the barrier. Remember you also need to pull the lever in front of the barrier."
	],
	4: [
		"I think I found who did all that mess! There's a robot blocking the road and it pushes back and hurts anyone who tries to go past him.",
		"We should find a way to disable it, or at least calm it down, however I don't know how to do that. I only know that you need to use a computer connected to the robot, it should be next to the robot. Try to find a book with the necessary knowledge to use that computer.",
		"There's a closed chest somewhere, maybe you can find something useful in it, but you need a key to open it. I actually had found a key, but I lost it. I probably dropped it on the ground. Woops."
	],
	5: [
		"Looks like you fixed the robot, good job! Now we should continue and check if he did any more damage."
	],
	6: [
		"Finally, here you are. I met a talking computer that wanted me to fix his friends and his network, but I am not very good with networks, so I will let you do the work.",
	],
	7: [
		"Wow, I didn't know you had to press a button to turn on those computers, my laptop turns on automatically when I open its lid."
	],
	8: [
		"What even is an access point anyway? Is it edible?"
	],
	9: [
		"You fool, you fell right into my trap! You have all the knowledge that I need to finally graduate. All I have to do now is to get it from you and get out of this place.",
		"Now, get ready to fight. Beware, I don't have any books, but I have MessageGPT Premium subscription, which will be more than enough to defeat you! You must be worse than such an expensive AI subscription, am I right?"
	],
	10: [
		"Impossible... h-how did you..? I didn't know studying could be more powerful than an AI premium subscription. So, the only way to get my degree is studying? But that will take me another 3 years at least!",
		"NOOOOOOOOOOOOOOOOOOOOOOOOOOOO!!!"
	]
}

func _ready() -> void:
	# finché nessuno mi parla deve rimanere nascosto
	hide()
	Global.start_dialog.connect(avvia_dialogo_fuoricorso)
	Global.start_robot_dialog.connect(avvia_dialogo_robot)
	Global.start_computer_dialog.connect(avvia_dialogo_computer)
	Global.start_player_dialog.connect(avvia_dialogo_player)
	
func _process(delta: float) -> void:
	if GameState.in_dialogue:
		if Input.is_action_just_pressed("Pick_object"):
			_on_next_pressed()
	
func avvia_dialogo_player():
	whos_talking = "player"
	avvia_dialogo_quest()
	
func avvia_dialogo_computer():
	whos_talking = "computer"
	avvia_dialogo_quest()
	
func avvia_dialogo_robot():
	whos_talking = "robot"
	avvia_dialogo_quest()
	
func avvia_dialogo_fuoricorso():
	whos_talking = ""
	avvia_dialogo_quest()

func avvia_dialogo_quest() -> void:
	if !visible:
		index = 0
		show()
		mostra_riga_corrente()
		await get_tree().create_timer(0.1).timeout
		GameState.in_dialogue = true
		Global.emit_signal("in_dialogo",true)


func mostra_riga_corrente() -> void:
	var righe: Array
	if whos_talking == "player":
		righe = dialoghi_player.get(QuestCounter.get_counter(),["..."])
	elif whos_talking == "robot":
		righe = dialoghi_robot.get(QuestCounter.get_counter(),["..."])
	elif whos_talking == "computer":
		righe = dialoghi_computer.get(QuestCounter.get_counter(),["..."])
	else :
		#parla npc fuoricorso
		righe = dialoghi_per_quest.get(QuestCounter.get_counter(),["..."])
	label.text = righe[index]

func _on_next_pressed() -> void:
	var righe: Array
	
	if whos_talking == "player":
		righe = dialoghi_player.get(QuestCounter.get_counter(),["..."])
	elif whos_talking == "robot":
		righe = dialoghi_robot.get(QuestCounter.get_counter(),["..."])
	elif whos_talking == "computer":
		righe = dialoghi_computer.get(QuestCounter.get_counter(),["..."])
	else:
		#parla npc fuoricorso
		righe = dialoghi_per_quest.get(QuestCounter.get_counter(),["..."])
		
	if index < righe.size() - 1:
		# mostra riga successiva
		index += 1
		mostra_riga_corrente()
	else:
		Global.emit_signal("in_dialogo",false)   #per mostrare gli altri tasti
		Global.emit_signal("fine_dialogo")
		if whos_talking == "player":
			Global.emit_signal("fine_dialogo_player")
		elif whos_talking == "robot":
			Global.emit_signal("fine_dialogo_robot")
		elif whos_talking == "computer":
			Global.emit_signal("fine_dialogo_computer")
		whos_talking = ""
		hide()
		await get_tree().create_timer(0.1).timeout  #aspetto altrimenti creo conflitti :(
		GameState.in_dialogue = false            #per sbloccare l'input
