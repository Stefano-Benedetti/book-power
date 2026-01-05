extends Resource

#main script dell'inventario

class_name Inv

signal update

@export var slots: Array[InvSlot]

func insert(item: InvItem):
	var emptyslots= slots.filter(func(slot): return slot.item == null)		#restituisce un array con i soli slot liberi
	if !emptyslots.is_empty():												#se l'array non è vuoto
		emptyslots[0].item = item											#assegna al primo degli slot libero l'item da inserire
	
	update.emit()
