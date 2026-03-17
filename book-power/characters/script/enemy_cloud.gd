extends Control

@onready var label = $Label
@onready var bubble = $TextureRect

var texts = [
	"giovani\nscansafatiche",
	"siete\nsvogliatiii",
	"ai miei\ntempi...",
	"sempre col\ntelefono ;|"
]

func _ready():
	randomize()

func randomText():
	var i = randi() % texts.size()
	label.text = texts[i]
