extends Area2D

const FALL_SPEED := 520.0
const RAIN_POWER := 0.35
const DESPAWN_Y := 800.0

var velocity := Vector2(0.0, FALL_SPEED)
var _handled := false


func _physics_process(delta: float) -> void:
	position += velocity * delta
	if position.y > DESPAWN_Y:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if _handled:
		return
	_handled = true
	monitoring = false

	if area is TreeCell:
		area.apply_rain(RAIN_POWER)
		queue_free()
	elif area is LandPatch:
		area.apply_rain(RAIN_POWER)
		queue_free()
	elif area is Ground:
		var hit_position := global_position
		var main := get_tree().current_scene
		main.call_deferred("_on_ground_rained", hit_position, RAIN_POWER)
		queue_free()
