extends StaticBody2D

var opened = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.animation = "open"
	$AnimatedSprite2D.frame = 0
	Global.leva_tirata.connect(open)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func open():
	$AnimatedSprite2D.play("open")
	opened = true
	$CollisionShapeChiuso.queue_free()
