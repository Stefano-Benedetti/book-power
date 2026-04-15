extends Node

#questo segnale viene chiamato da inv_ui quando aggiorna gli slot e viene captato da selectedItem_slot
signal selected_slot_update(slot: InvSlot, indice)

signal death
signal start_dialog

signal in_dialogo

signal fine_dialogo

signal quadro_attivato
signal leva_tirata

signal removeRoadblock

signal fixElSys

signal sbloccaRobot

signal start_robot_dialog

signal muovi_robot

signal fine_dialogo_robot

signal incrementCounter
signal totalReached

signal start_computer_dialog

signal fine_dialogo_computer

signal removeFireWall

func getData():
	var data = {
		"global_volume" = db_to_linear(AudioServer.get_bus_volume_db(0)),
		"effects_volume" = db_to_linear(AudioServer.get_bus_volume_db(1)),
		"music_volume" = db_to_linear(AudioServer.get_bus_volume_db(2)),
		"current_level" = Progress.livello_corrente,
		"inventory" = Progress.inventory
	}
	return data
