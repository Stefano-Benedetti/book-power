extends ProgressBar

@export var player: Player

func _ready():
	player.health_changhed.connect(update)
	update()

func update():
	value = player.current_health / player.max_health * 100
