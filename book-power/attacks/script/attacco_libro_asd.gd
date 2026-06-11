extends Node2D

const DAMAGE = 25
static var atk_cooldown = 1
static var move_cooldown = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()
	$FreesoundCommunitySortdemoQb45Bubble33039.play()
	await get_tree().create_timer(0.8).timeout
	queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if not area.is_in_group("enemies_hitbox"):
		return
	var enemy = area.get_parent()
	if enemy.has_method("enemy"):	#verifico se è effettivamente un nemico
		enemy.getHurt(DAMAGE)
