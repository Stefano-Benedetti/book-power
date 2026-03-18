extends Node

#questo segnale viene chiamato da inv_ui quando aggiorna gli slot e viene captato da selectedItem_slot
signal selected_slot_update(slot: InvSlot, indice)

signal death
signal start_dialog
