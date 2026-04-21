extends ColorRect

var tween

func _ready() -> void:
	modulate.a = 0.0

func _process(delta: float) -> void:
	pass


func appari():
	# Fade in
	create_tween().tween_property(self, "modulate:a", 1.0, 1)

func sparisci():
	# Fade out
	create_tween().tween_property(self, "modulate:a", 0.0, 1)
