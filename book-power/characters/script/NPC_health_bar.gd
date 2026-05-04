extends TextureProgressBar


@export var character: CharacterBody2D

func _ready():
	value = character.max_health

func update():
	value = character.current_health * 100 / character.max_health
