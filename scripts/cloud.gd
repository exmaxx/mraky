extends CharacterBody2D

signal lightning_requested

const MOVE_SPEED := 280.0
const RAIN_INTERVAL := 0.06
const LIGHTNING_COOLDOWN := 0.7

@export var rain_scene: PackedScene

var world_bounds_x := Vector2(60.0, 1220.0)
var _rain_cooldown := 0.0
var _lightning_cooldown := 0.0


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * MOVE_SPEED
	move_and_slide()
	position.x = clampf(position.x, world_bounds_x.x, world_bounds_x.y)

	_rain_cooldown = maxf(_rain_cooldown - delta, 0.0)
	if Input.is_action_pressed("rain") and _rain_cooldown <= 0.0:
		_spawn_rain()
		_rain_cooldown = RAIN_INTERVAL

	_lightning_cooldown = maxf(_lightning_cooldown - delta, 0.0)
	if Input.is_action_pressed("lightning") and _lightning_cooldown <= 0.0:
		lightning_requested.emit()
		_lightning_cooldown = LIGHTNING_COOLDOWN


func _spawn_rain() -> void:
	if rain_scene == null:
		return

	var drop: Area2D = rain_scene.instantiate()
	drop.position = global_position + Vector2(randf_range(-36.0, 36.0), 18.0)
	get_tree().current_scene.get_node("World").add_child(drop)
