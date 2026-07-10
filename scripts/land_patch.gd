class_name LandPatch
extends Area2D

const WATER_TO_EXPAND := 0.5
const WATER_TO_SPAWN_TREE := 1.0
const MAX_RADIUS := 26.0
const BASE_RADIUS := 5.0

signal tree_spawn_ready(patch: LandPatch)

var water: float = 0.0
var patch_radius: float = BASE_RADIUS
var has_tree: bool = false

@onready var patch: Polygon2D = $Patch


func _ready() -> void:
	z_index = int(global_position.x) % 1000
	_update_visual()


func apply_rain(amount: float) -> float:
	water += amount
	patch_radius = minf(MAX_RADIUS, BASE_RADIUS + water * 12.0)
	_update_visual()
	if can_spawn_tree():
		call_deferred("_notify_tree_ready")
	return water


func _notify_tree_ready() -> void:
	if can_spawn_tree():
		tree_spawn_ready.emit(self)


func can_spawn_tree() -> bool:
	return not has_tree and water >= WATER_TO_SPAWN_TREE


func mark_has_tree() -> void:
	has_tree = true


func _update_visual() -> void:
	var dryness := 1.0 - clampf(water / WATER_TO_SPAWN_TREE, 0.0, 1.0)
	var dry_color := Color(0.52, 0.38, 0.22)
	var wet_color := Color(0.28, 0.58, 0.18)
	patch.color = dry_color.lerp(wet_color, 1.0 - dryness)

	var r := patch_radius
	patch.polygon = PackedVector2Array([
		Vector2(-r, 0),
		Vector2(-r * 0.6, -r * 0.25),
		Vector2(0, -r * 0.35),
		Vector2(r * 0.6, -r * 0.25),
		Vector2(r, 0),
	])
