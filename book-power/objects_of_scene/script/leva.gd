extends StaticBody2D


var player_in_area = false
var player = null
@export var funzionante: bool

@export var one_shot: bool	#per indicare se la leva può essere ritirata più volte
var tirata = false	#per indicare se la leva è stata tirata

func _ready():
	$button_icon.hide()
	Global.quadro_attivato.connect(rendi_funzionante)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not funzionante:
		return
	if one_shot and tirata:
		return
	if player_in_area:
		if Input.is_action_just_pressed("Pick_object"):
			$Sprite2D.flip_h = true
			tirata = true
			Global.leva_tirata.emit()
			$LeverSound.play()

func rendi_funzionante():
	funzionante = true

func _on_area_of_interaction_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true
		player = body
		if funzionante and not tirata:
			mostra_button()
		Global.pickIncrement()

func _on_area_of_interaction_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
		$button_icon.hide()
		Global.pickDecrement()


func mostra_button():
	$button_icon.show()
	while player_in_area:
		if tirata:
			$button_icon.hide()
			break
		$button_icon.modulate.a = 1
		await get_tree().create_timer(0.7).timeout
		$button_icon.modulate.a = 0.5
		await get_tree().create_timer(0.5).timeout
