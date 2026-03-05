extends TextureProgressBar


@export var enemy: Enemy

func _ready():
	value = enemy.max_health

func update():
	print(enemy.max_health)
	value = enemy.current_health * 100 / enemy.max_health 
