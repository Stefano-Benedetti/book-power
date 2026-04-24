extends Node2D



@export var speed_px_per_sec: float = 80.0
@export var start_padding: float = -1350.0
@export var end_padding: float = 250.0

@onready var box: VBoxContainer = $CanvasLayer/VBoxContainer

@onready var rtl1: RichTextLabel = $CanvasLayer/VBoxContainer/section2/link_characters
@onready var rtl2: RichTextLabel = $CanvasLayer/VBoxContainer/section3/link_robot
@onready var rtl3: RichTextLabel = $CanvasLayer/VBoxContainer/section4/link_bats
@onready var rtl4: RichTextLabel = $CanvasLayer/VBoxContainer/section7/link_items
@onready var rtl5: RichTextLabel = $CanvasLayer/VBoxContainer/section8/link_inventory


func _ready() -> void:
	
	rtl1.bbcode_enabled = true
	rtl2.bbcode_enabled = true
	rtl3.bbcode_enabled = true
	rtl4.bbcode_enabled = true
	rtl5.bbcode_enabled = true
	
	await get_tree().process_frame

	var start_y = box.size.y + start_padding
	var end_y = -box.size.y - end_padding
	box.position.y = start_y

	var distance = abs(start_y - end_y)
	var duration = distance / speed_px_per_sec

	var tw = create_tween()
	tw.tween_property(box, "position:y", end_y, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tw.finished.connect(func():
		# cambia scena
		get_tree().quit()
		)

func _on_link_meta_clicked(meta: Variant) -> void:
	# meta di solito è una String (l’URL)
	if meta is String:
		OS.shell_open(meta)
