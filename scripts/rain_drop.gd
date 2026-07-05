extends Area2D

const FALL_SPEED := 520.0
const RAIN_POWER := 0.35

var velocity := Vector2(0.0, FALL_SPEED)


func _physics_process(delta: float) -> void:
	position += velocity * delta
	if position.y > 800.0:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is TreeCell:
		area.apply_rain(RAIN_POWER)
		queue_free()
