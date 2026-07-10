class_name Ground
extends Area2D

signal rained_at(world_position: Vector2, amount: float)

@onready var collision: CollisionShape2D = $CollisionShape2D


func set_ground_width(width: float) -> void:
	var rect := collision.shape as RectangleShape2D
	rect.size = Vector2(width, 40.0)
	collision.position = Vector2(width * 0.5, 20.0)


func apply_rain(world_position: Vector2, amount: float) -> void:
	rained_at.emit(world_position, amount)
