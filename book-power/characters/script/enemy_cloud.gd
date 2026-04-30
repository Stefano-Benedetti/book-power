extends Control

@onready var label = $Label
@onready var bubble = $TextureRect

var texts = [
  "You're so lazy.",
  "Get back to work, slacker!",
  "Back in my day...",
  "Always on your phone!"
]

func _ready():
	randomize()

func randomText():
	var i = randi() % texts.size()
	label.text = texts[i]
