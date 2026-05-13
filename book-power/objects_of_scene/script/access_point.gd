extends Node2D

@export var item: InvItem	#va messo perchè è un oggetto collezionabile

var player_in_area = false
var player = null

var pickable = true

func _ready():
	$button_icon.hide()
	$AnimatedSprite2D.play("AP_spento")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player_in_area and pickable :
		if Input.is_action_just_pressed("Pick_object"):
			var has_picked = player.collect(item)
			if(has_picked):
				queue_free()

func playConnecting():
	$AnimatedSprite2D.play("connecting")

func _on_pickable_area_body_entered(body: Node2D) -> void:
	if body.has_method("player") and pickable:
		player_in_area = true
		player = body
		mostra_button()
		Global.pickIncrement()


func _on_pickable_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
		$button_icon.hide()
		Global.pickDecrement()


func mostra_button():
	$button_icon.show()
	while player_in_area:
		$button_icon.modulate.a = 1
		await get_tree().create_timer(0.7).timeout
		$button_icon.modulate.a = 0.5
		await get_tree().create_timer(0.5).timeout
