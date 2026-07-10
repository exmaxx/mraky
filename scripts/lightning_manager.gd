extends Node

const MIN_INTERVAL := 7.0
const MAX_INTERVAL := 14.0
const STRIKE_RANGE_X := 90.0

@export var lightning_scene: PackedScene

var _trees: Array[TreeCell] = []
var _timer := 2.0
var _get_ground_y: Callable


func setup(trees: Array[TreeCell], get_ground_y: Callable) -> void:
	_trees = trees
	_get_ground_y = get_ground_y
	_timer = randf_range(MIN_INTERVAL, MAX_INTERVAL)


func register_tree(tree: TreeCell) -> void:
	_trees.append(tree)


func _process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return

	_timer = randf_range(MIN_INTERVAL, MAX_INTERVAL)
	var cloud: Node2D = get_tree().current_scene.get_node("World/Cloud")
	strike_at(cloud.global_position)


func strike_at(from_position: Vector2) -> void:
	var strike_position := Vector2(from_position.x, _get_ground_y.call())
	var target := _find_nearest_tree(from_position)
	if target:
		strike_position = target.global_position
		target.ignite()

	_spawn_lightning(strike_position)


func _find_nearest_tree(from_position: Vector2) -> TreeCell:
	var best: TreeCell = null
	var best_dist := STRIKE_RANGE_X
	for tree in _trees:
		if not is_instance_valid(tree):
			continue
		if not tree.can_be_struck():
			continue
		var dist := absf(tree.global_position.x - from_position.x)
		if dist < best_dist:
			best_dist = dist
			best = tree
	return best


func _spawn_lightning(target_position: Vector2) -> void:
	if lightning_scene == null:
		return

	var strike: Node2D = lightning_scene.instantiate()
	strike.global_position = target_position
	get_tree().current_scene.get_node("World").add_child(strike)
