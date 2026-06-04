extends Node2D

@export var required_item : InvItem

@export var object_ap : PackedScene

var talked_with_computer = false

#var player_in_ap_area = false

var player_in_cave = false
var player_in_cave_entrance = false
var player_in_cave_exit = false

var player

func _ready() -> void:
	$place_router.drop_key.connect(AP_dropped)
	Musica.gaming_music.play()
	
	# carico inventario player
	$player.inv.clean()
	for slot in Progress.inventory.slots:
		$player.inv.insert(slot.item)
	
	Global.fine_dialogo_computer.connect(updateFirewallAndDropBook)
	Global.fine_dialogo_computer.connect(useOfCounter)
	Global.totalReached.connect(turnedComputersOn)
	$player.current_dir = "right"
	QuestCounter.quest_corrente = 6
	$CanvasLayer2/counter.hide()

func _process(delta: float) -> void:
	print(QuestCounter.quest_corrente)
	if player_in_cave_entrance and player.current_dir == "up":
		player.position = $spawn_caverna.position
		player_in_cave = true
		player_in_cave_entrance = false
	if player_in_cave_exit and player.current_dir == "down":
		player.position = $fuori_caverna.position
		player_in_cave = false
		player_in_cave_exit = false

func updateFirewallAndDropBook():
	if QuestCounter.quest_corrente == 8:
		Global.emit_signal("removeFireWall")
		$computer_parlante.dropObject()

func turnedComputersOn():
	QuestCounter.quest_corrente = 7

func useOfCounter():
	if not talked_with_computer:
		talked_with_computer = true
		$CanvasLayer2/counter.show()
	if QuestCounter.quest_corrente == 7:
		$CanvasLayer2/counter.hide()

func _on_to_next_level_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		#se non si sta runnando game non passa al livello successivo
		if get_parent().name != "game":
			return
		
		#salvo il livello corrente nella classe dei progressi
		Progress.livello_corrente = 5
		
		#salvo inventario nella classe dei progressi
		Progress.inventory.clean()
		for slot in $player.inv.slots:
			Progress.inventory.insert(slot.item)
		
		#salvataggio dati
		var data = Global.getData()
		SaveSystem.save_data(data)
		
		Musica.stopMusic()
		
		get_parent().loadNextLevel()


func AP_dropped():
	if QuestCounter.quest_corrente == 7:
		useOfCounter()
		QuestCounter.quest_corrente = 8
		player.consumeItem(required_item,1)
		if object_ap == null:
			return
		var scena_dropped_object = object_ap.instantiate()
		add_child(scena_dropped_object)
		scena_dropped_object.global_position = Vector2(927.802,-576.853)
		scena_dropped_object.playConnecting()
		scena_dropped_object.pickable = false
		object_ap = null
		$place_router.key_dropped = true
		Global.pickDecrement()


#func _on_place_router_body_entered(body: Node2D) -> void:
	#if body.has_method("player"):
		#player_in_ap_area = true
		#player = body
#
#func _on_place_router_body_exited(body: Node2D) -> void:
	#if body.has_method("player"):
		#player_in_ap_area = false
		
func _on_cave_entrance_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_cave_entrance = true
		player = body
		Musica.stopMusic()
		Musica.cave_music.play()

func _on_cave_entrance_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_cave_entrance = false


func _on_cave_exit_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_cave_exit = true
		player = body
		Musica.stopMusic()
		Musica.gaming_music.play()


func _on_cave_exit_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_cave_exit = false
