extends Panel

#chiamiamo nel codice item_display col nome di item_visual
@onready var item_visual: Sprite2D = $CenterContainer/Panel/item_display

func update(item: InvItem):
	if !item:
		item_visual.visible = false
	else:
		item_visual.visible = true
		item_visual.texture = item.texture
