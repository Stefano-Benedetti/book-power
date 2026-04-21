extends ColorRect

var tween

func _ready() -> void:
	modulate.a = 0.0

func _process(delta: float) -> void:
	pass


func appari(time_to_show):
	# Fade in
	create_tween().tween_property(self, "modulate:a", 1.0, time_to_show)

func sparisci(time_to_hide):
	# Fade out
	create_tween().tween_property(self, "modulate:a", 0.0, time_to_hide)
