extends Node2D

@export var item: InvItem	#va messo perchè è un oggetto collezionabile

var has_picked = false

var player_in_area = false
var player = null

@export var float_height: float = 1.0      # quanto sale/scende
@export var float_speed: float = 3.0        # velocità oscillazione
@export var shadow_scale_min: float = 0.35   # ombra più piccola (quando oggetto è alto)
@export var shadow_scale_max: float = 0.45   # ombra più grande (quando oggetto è basso)

@onready var sprite = $Sprite2D
@onready var shadow = $Shadow

var time := 0.0
var base_y := 0.0

func _ready():
	$button_icon.hide()
	base_y = sprite.position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	time += _delta * float_speed
	var offset = sin(time) * float_height	# Movimento fluido con sinusoide
	sprite.position.y = base_y + offset
	var t = (offset + float_height) / (2.0 * float_height)		# Normalizza il valore tra 0 e 1
	var shadow_scale = lerp(shadow_scale_max, shadow_scale_min, t)	# Scala ombra (inverso: più alto = ombra più piccola)
	shadow.scale = Vector2.ONE * shadow_scale
	
	if player_in_area:
		if Input.is_action_just_pressed("Pick_object") and not has_picked:
			has_picked = true
			has_picked = player.collect(item)
			if(has_picked):
				if !$AngelicChoir.playing:
					$AngelicChoir.play()
					hide()
					await get_tree().create_timer(2).timeout
					queue_free()


func _on_pickable_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
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
