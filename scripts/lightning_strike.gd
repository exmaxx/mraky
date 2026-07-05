extends Node2D

const DURATION := 0.35

var _elapsed := 0.0


func _ready() -> void:
	$Bolt.points = PackedVector2Array([
		Vector2(0, -420),
		Vector2(randf_range(-18, 18), -280),
		Vector2(randf_range(-12, 12), -140),
		Vector2(0, 0),
	])
	$Flash.modulate.a = 0.6


func _process(delta: float) -> void:
	_elapsed += delta
	modulate.a = 1.0 - (_elapsed / DURATION)
	if _elapsed >= DURATION:
		queue_free()
