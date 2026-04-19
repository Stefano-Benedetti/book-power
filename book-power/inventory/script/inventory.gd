extends Resource

#main script dell'inventario

class_name Inv

signal update

@export var slots: Array[InvSlot]

func insert(item: InvItem):
	var emptyslots= slots.filter(func(slot): return slot.item == null)		#restituisce un array con i soli slot liberi
	if emptyslots.is_empty():												#se l'array è vuoto
		return false
	else:
		emptyslots[0].item = item											#assegna al primo degli slot libero l'item da inserire
		update.emit()
		return true


func delete(indice):
	slots[indice].item = null
	update.emit()

# restituisce il numero di item specificati presenti nell'inventario
func countItem(item: InvItem):
	var slots_with_item = slots.filter(func(slot): return slot.item == item)
	return slots_with_item.size()

func contain(item: InvItem):
	for slot in slots:
		if slot.item == item:
			return true
	return false

func clean():
	for slot in slots:
		slot.item = null
