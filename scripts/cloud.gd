extends CharacterBody2D

const MOVE_SPEED := 280.0
const RAIN_INTERVAL := 0.06

@export var rain_scene: PackedScene

var _rain_cooldown := 0.0


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * MOVE_SPEED
	move_and_slide()

	_rain_cooldown = maxf(_rain_cooldown - delta, 0.0)
	if Input.is_action_pressed("rain") and _rain_cooldown <= 0.0:
		_spawn_rain()
		_rain_cooldown = RAIN_INTERVAL

	$Shadow.position = Vector2(0, 28)


func _spawn_rain() -> void:
	if rain_scene == null:
		return

	var drop: Area2D = rain_scene.instantiate()
	drop.position = global_position + Vector2(randf_range(-36.0, 36.0), 18.0)
	get_tree().current_scene.get_node("World").add_child(drop)
