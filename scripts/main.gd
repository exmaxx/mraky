extends Node2D

const GRID_COLS := 20
const GRID_ROWS := 10
const CELL_SIZE := 56.0

@export var tree_scene: PackedScene

@onready var world: Node2D = $World
@onready var lightning_manager: Node = $LightningManager
@onready var forest_label: Label = $UI/HUD/ForestLabel
@onready var fire_label: Label = $UI/HUD/FireLabel

var _trees: Array[Node] = []


func _ready() -> void:
	_build_forest()
	lightning_manager.setup(_trees)


func _process(_delta: float) -> void:
	_update_hud()


func _build_forest() -> void:
	var origin := Vector2(120.0, 180.0)
	for row in GRID_ROWS:
		for col in GRID_COLS:
			var tree: TreeCell = tree_scene.instantiate()
			tree.position = origin + Vector2(col * CELL_SIZE, row * CELL_SIZE)
			world.add_child(tree)
			if randf() < 0.35:
				var initial_state := TreeCell.State.GROWING if randf() < 0.5 else TreeCell.State.MATURE
				tree.setup_initial(initial_state)
			_trees.append(tree)


func _update_hud() -> void:
	var mature := 0
	var burning := 0
	for tree in _trees:
		if not is_instance_valid(tree):
			continue
		match tree.state:
			TreeCell.State.MATURE:
				mature += 1
			TreeCell.State.BURNING:
				burning += 1
	forest_label.text = "Zraly les: %d" % mature
	fire_label.text = "Hori: %d" % burning
