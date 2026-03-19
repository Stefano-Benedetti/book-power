extends Node2D
class_name AINavManager

@export var groups_count := 3
@export var tick_time := 0.12 # ogni quanto cambia turno (regola)
var _acc := 0.0
var _turn := 0

var _groups: Array = []

func _ready() -> void:
	_groups.resize(groups_count)
	for i in range(groups_count):
		_groups[i] = []

func register_enemy(enemy: Node, group_id: int) -> void:
	group_id = posmod(group_id, groups_count)
	_groups[group_id].append(enemy)

func unregister_enemy(enemy: Node, group_id: int) -> void:
	group_id = posmod(group_id, groups_count)
	_groups[group_id].erase(enemy)

func _process(delta: float) -> void:
	_acc += delta
	if _acc < tick_time:
		return
	_acc = 0.0

	_turn = (_turn + 1) % groups_count
	for e in _groups[_turn]:
		if is_instance_valid(e):
			e.nav_tick() # chiamata sul nemico
