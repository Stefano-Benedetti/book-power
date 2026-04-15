extends Label

@export var totale: int
@export var corrente: int

var raggiunto = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = str(corrente)+"/"+str(totale)
	Global.incrementCounter.connect(increment)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if corrente < totale or raggiunto:
		return
	Global.totalReached.emit()
	raggiunto = true

func increment():
	corrente += 1
	text = str(corrente)+"/"+str(totale)
