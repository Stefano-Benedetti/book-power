extends Sprite2D

@export var float_height: float = 1.0      # quanto sale/scende
@export var float_speed: float = 3.0        # velocità oscillazione

var stopped = true

var time := 0.0
var base_y := 0.0

func _ready():
	hide()
	base_y = position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not stopped:
		time += _delta * float_speed
		var offset = sin(time) * float_height	# Movimento fluido con sinusoide
		position.y = base_y + offset


func stop():
	stopped = true
	hide()

func showAndStart():
	stopped = false
	show()
