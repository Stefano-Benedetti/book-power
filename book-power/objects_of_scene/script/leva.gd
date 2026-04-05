extends StaticBody2D


var player_in_area = false
var player = null
@export var funzionante: bool

@export var one_shot: bool	#per indicare se la leva può essere ritirata più volte
var tirata = false	#per indicare se la leva è stata tirata

func _ready():
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

func rendi_funzionante():
	funzionante = true

func _on_area_of_interaction_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true
		player = body

func _on_area_of_interaction_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
