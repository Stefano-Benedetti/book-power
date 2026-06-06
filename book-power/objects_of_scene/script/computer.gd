extends Node2D

@onready var mappa_corrente = get_parent().name
@export var chiave: InvItem

var player_in_area = false
var player = null

var used = false
var offset_drop = Vector2(0, 10)

var talked_with_computer = false

var button_visible = false

func _ready() -> void:
	$button_icon_pick.hide()
	$button_icon_attack.hide()
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
		$button_icon_pick.hide()
		$button_icon_attack.hide()
	elif not button_visible:
		mostra_button($button_icon_attack)

func fourthMapBehavior():
	if used or not player_in_area or not talked_with_computer:
		return
	if Input.is_action_just_pressed("Pick_object"):
		Global.incrementCounter.emit()
		$AnimatedSprite2D.animation = "turn_blue_screen"
		used = true
		Global.pickDecrement()
		$button_icon_pick.hide()
		$button_icon_attack.hide()

func talkedWithComputer():
	talked_with_computer = true

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true
		player = body
		if mappa_corrente == "mappa04" and talked_with_computer and !used:
			mostra_button($button_icon_pick)
			Global.pickIncrement()

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
		$button_icon_pick.hide()
		$button_icon_attack.hide()
		button_visible = false
		if mappa_corrente == "mappa04" and talked_with_computer and !used:
			Global.pickDecrement()


func mostra_button(button):
	button_visible = true
	button.show()
	while player_in_area and not used:
		if mappa_corrente == "mappa03" and player.selected_item!=chiave:
			button.hide()
			button_visible = false
			break
		button.modulate.a = 1
		await get_tree().create_timer(0.7).timeout
		button.modulate.a = 0.5
		await get_tree().create_timer(0.5).timeout
