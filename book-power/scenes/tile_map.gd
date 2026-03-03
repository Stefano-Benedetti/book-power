#extends TileMap
#
#
#func _use_tile_data_runtime_update(layer, coords):
	#if coords in get_used_cells_by_id(1):
		#return true
	#else:
		#return false
#
#func _tile_data_runtime_update(layer, coords, tile_data):
	#tile_data.set_navigation_polygon(0, null)

extends TileMap

const GROUND_LAYER = 0
const OBSTACLE_LAYER = 1

#func _ready():
	#notify_runtime_tile_data_update()

func _use_tile_data_runtime_update(layer, coords):
	# Ci interessa modificare solo il terreno
	print("aaaaaaaaaaaaaaaa")
	if layer != GROUND_LAYER:
		return false

	# Se in quella posizione c'è un tile nel layer ostacoli
	if get_cell_source_id(OBSTACLE_LAYER, coords) != -1:
		return true

	return false


func _tile_data_runtime_update(layer, coords, tile_data):
	# Rimuove la navigation dal terreno
	tile_data.set_navigation_polygon(0, null)
	print("Update:", coords)
