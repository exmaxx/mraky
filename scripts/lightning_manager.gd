extends Node

const MIN_INTERVAL := 2.5
const MAX_INTERVAL := 5.5

@export var lightning_scene: PackedScene

var _trees: Array[Node] = []
var _timer := 2.0


func setup(trees: Array[Node]) -> void:
	_trees = trees
	_timer = randf_range(MIN_INTERVAL, MAX_INTERVAL)


func _process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return

	_timer = randf_range(MIN_INTERVAL, MAX_INTERVAL)
	_strike_random_tree()


func _strike_random_tree() -> void:
	var candidates: Array[Node] = []
	for tree in _trees:
		if is_instance_valid(tree) and tree.has_method("can_be_struck") and tree.can_be_struck():
			candidates.append(tree)

	if candidates.is_empty():
		return

	var target: Node = candidates.pick_random()
	_spawn_lightning(target.global_position)
	target.ignite()


func _spawn_lightning(target_position: Vector2) -> void:
	if lightning_scene == null:
		return

	var strike: Node2D = lightning_scene.instantiate()
	strike.global_position = target_position
	get_tree().current_scene.get_node("World").add_child(strike)
