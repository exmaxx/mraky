extends Node2D

const DESIGN_SIZE := Vector2(1280.0, 720.0)
const WORLD_MARGIN_X := DESIGN_SIZE.x
const WORLD_LEFT := -WORLD_MARGIN_X
const WORLD_WIDTH := DESIGN_SIZE.x + WORLD_MARGIN_X * 2.0
const GROUND_HEIGHT := 160.0
const LAND_MERGE_RADIUS := 22.0
const CLOUD_EDGE_MARGIN := 60.0

@export var tree_scene: PackedScene
@export var land_scene: PackedScene

@onready var sky: ColorRect = $Sky
@onready var ground_visual: ColorRect = $GroundVisual
@onready var ground: Ground = $World/Ground
@onready var world: Node2D = $World
@onready var cloud: CharacterBody2D = $World/Cloud
@onready var lightning_manager: Node = $LightningManager
@onready var forest_label: Label = $UI/HUD/ForestLabel
@onready var fire_label: Label = $UI/HUD/FireLabel

var _trees: Array[TreeCell] = []
var _land_patches: Array[LandPatch] = []
var _ground_y: float = DESIGN_SIZE.y - GROUND_HEIGHT


func _ready() -> void:
	_apply_stretch_settings()
	_setup_world_bounds()
	ground.rained_at.connect(_on_ground_rained)
	cloud.lightning_requested.connect(_on_cloud_lightning)
	_scatter_initial_tree_groups()
	lightning_manager.setup(_trees, _get_ground_strike_y)


func _apply_stretch_settings() -> void:
	var win := get_window()
	win.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP


func _setup_world_bounds() -> void:
	sky.offset_left = WORLD_LEFT
	sky.offset_right = WORLD_LEFT + WORLD_WIDTH
	ground_visual.offset_left = WORLD_LEFT
	ground_visual.offset_right = WORLD_LEFT + WORLD_WIDTH
	ground.position.x = WORLD_LEFT
	ground.set_ground_width(WORLD_WIDTH)
	cloud.world_bounds_x = Vector2(
		WORLD_LEFT + CLOUD_EDGE_MARGIN,
		WORLD_LEFT + WORLD_WIDTH - CLOUD_EDGE_MARGIN
	)
	var camera := cloud.get_node("Camera2D") as Camera2D
	camera.limit_left = int(WORLD_LEFT)
	camera.limit_right = int(WORLD_LEFT + WORLD_WIDTH)
	camera.limit_top = 0
	camera.limit_bottom = int(DESIGN_SIZE.y)


func _get_ground_strike_y() -> float:
	return ground.global_position.y


func _scatter_initial_tree_groups() -> void:
	var group_count := 5
	for _g in group_count:
		var center_x := randf_range(WORLD_LEFT + 140.0, WORLD_LEFT + WORLD_WIDTH - 140.0)
		var tree_count := randi_range(3, 6)
		for _i in tree_count:
			var x := center_x + randf_range(-50.0, 50.0)
			var patch := _spawn_land_patch(Vector2(x, _ground_y), randf_range(1.0, 1.6))
			patch.mark_has_tree()
			var stage := randi_range(0, 3) as TreeCell.Stage
			_spawn_tree_on_land(patch, stage, randf_range(0.2, 0.8))


func _on_ground_rained(world_position: Vector2, amount: float) -> void:
	var patch := _find_nearby_land(world_position)
	if patch:
		patch.apply_rain(amount)
		_try_spawn_tree_on_land(patch)
	else:
		patch = _spawn_land_patch(world_position, amount)
		_try_spawn_tree_on_land(patch)


func _spawn_land_patch(world_position: Vector2, water: float) -> LandPatch:
	var patch: LandPatch = land_scene.instantiate()
	patch.position = Vector2(world_position.x, _ground_y)
	patch.tree_spawn_ready.connect(_on_land_tree_spawn_ready)
	world.add_child(patch)
	patch.apply_rain(water)
	_land_patches.append(patch)
	return patch


func _on_land_tree_spawn_ready(patch: LandPatch) -> void:
	_try_spawn_tree_on_land(patch)


func _find_nearby_land(world_position: Vector2) -> LandPatch:
	var best: LandPatch = null
	var best_dist := LAND_MERGE_RADIUS
	for patch in _land_patches:
		if not is_instance_valid(patch):
			continue
		var dist := absf(patch.global_position.x - world_position.x)
		if dist < best_dist:
			best_dist = dist
			best = patch
	return best


func _try_spawn_tree_on_land(patch: LandPatch) -> void:
	if not patch.can_spawn_tree():
		return
	patch.mark_has_tree()
	_spawn_tree_on_land(patch, TreeCell.Stage.SPROUT)


func _spawn_tree_on_land(patch: LandPatch, initial_stage: TreeCell.Stage, initial_water: float = 0.0) -> void:
	var tree: TreeCell = tree_scene.instantiate()
	tree.position = patch.position + Vector2(randf_range(-8.0, 8.0), 0.0)
	world.add_child(tree)
	tree.setup_initial(initial_stage, initial_water)
	_trees.append(tree)
	lightning_manager.register_tree(tree)


func _on_cloud_lightning() -> void:
	lightning_manager.strike_at(cloud.global_position)


func _process(_delta: float) -> void:
	_update_hud()


func _update_hud() -> void:
	var mature := 0
	var burning := 0
	for tree in _trees:
		if not is_instance_valid(tree):
			continue
		match tree.state:
			TreeCell.State.ALIVE:
				if tree.stage >= TreeCell.Stage.MATURE:
					mature += 1
			TreeCell.State.BURNING:
				burning += 1
	forest_label.text = "Zraly les: %d" % mature
	fire_label.text = "Hori: %d" % burning
