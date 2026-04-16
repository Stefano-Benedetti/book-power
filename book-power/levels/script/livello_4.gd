extends Node2D

@export var required_item : InvItem

@export var object_ap : PackedScene

var talked_with_computer = false

var player_in_ap_area = false

var player_in_cave_entrance = false

var player

func _ready() -> void:
	Global.fine_dialogo_computer.connect(talkedWithComputer)
	Global.fine_dialogo_computer.connect(endUseOfCounter)
	Global.totalReached.connect(turnedComputersOn)
	$player.current_dir = "right"
	QuestCounter.quest_corrente = 6
	$CanvasLayer2/counter.hide()

func _process(delta: float) -> void:
	if QuestCounter.quest_corrente == 7:
		if player_in_ap_area and Input.is_action_just_pressed("Pick_object") and player.inv.countItem(required_item)>0:
			endUseOfCounter()
			QuestCounter.quest_corrente = 8
			player.consumeItem(required_item,1)
			if object_ap == null:
				return
			var scena_dropped_object = object_ap.instantiate()
			add_child(scena_dropped_object)
			scena_dropped_object.global_position = Vector2(927.802,-576.853)
			#scena_dropped_object.play...
			Global.emit_signal("removeFireWall")
			object_ap = null
	if player_in_cave_entrance and player.current_dir == "up":
		player.position = Vector2(0,0)
		player_in_cave_entrance = false

func talkedWithComputer():
	if not talked_with_computer:
		talked_with_computer = true
		$CanvasLayer2/counter.show()

func turnedComputersOn():
	QuestCounter.quest_corrente = 7

func endUseOfCounter():
	if QuestCounter.quest_corrente == 7:
		$CanvasLayer2/counter.hide()

func _on_to_next_level_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		#se non si sta runnando game non passa al livello successivo
		if get_parent().name != "game":
			return
		Progress.livello_corrente = 5		#salvo il livello corrente nella classe dei progressi
		Progress.inventory = $player.inv	#salvo inventario nella classe dei progressi
		get_parent().loadNextLevel()


func _on_place_router_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_ap_area = true
		player = body

func _on_place_router_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_ap_area = false
		player = null
		
func _on_cave_entrance_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_cave_entrance = true
		player = body

func _on_cave_entrance_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_cave_entrance = false
		player = null
