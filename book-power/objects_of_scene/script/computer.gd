extends Node2D

@onready var mappa_corrente = get_parent().name
@export var chiave: InvItem

var player_in_area = false
var player = null

var used = false
var offset_drop = Vector2(0, 10)

var talked_with_computer = false

func _ready() -> void:
	if not talked_with_computer:
		Global.fine_dialogo_computer.connect(talkedWithComputer)
	if mappa_corrente == "mappa03":
		$AnimatedSprite2D.animation = "turn_red_screen"
	if mappa_corrente == "mappa04":
		$AnimatedSprite2D.animation = "turn_off"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if mappa_corrente == "mappa03":
		thirdMapBehavior()
	if mappa_corrente == "mappa04":
		fourthMapBehavior()

func thirdMapBehavior():
	if used or not player_in_area or not player.selected_item==chiave:
		return
	if Input.is_action_just_pressed("attacca"):
		Global.sbloccaRobot.emit()
		$AnimatedSprite2D.animation = "turn_green_screen"
		used = true

func fourthMapBehavior():
	if used or not player_in_area or not talked_with_computer:
		return
	if Input.is_action_just_pressed("Pick_object"):
		Global.incrementCounter.emit()
		$AnimatedSprite2D.animation = "turn_blue_screen"
		used = true

func talkedWithComputer():
	talked_with_computer = true

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true
		player = body

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
