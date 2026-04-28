extends Node2D

@export var item: InvItem	#va messo perchè è un oggetto collezionabile

var player_in_area = false
var player = null

var pickable = true

func _ready():
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
	if body.has_method("player"):
		player_in_area = true
		player = body


func _on_pickable_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
