class_name TreeCell
extends Area2D

enum Stage { SPROUT, SAPLING, YOUNG, MATURE, ANCIENT }
enum State { ALIVE, BURNING, BURNT }

const STAGE_THRESHOLDS := {
	Stage.SPROUT: 0.8,
	Stage.SAPLING: 1.0,
	Stage.YOUNG: 1.3,
	Stage.MATURE: 1.6,
	Stage.ANCIENT: 2.0,
}
const BURN_DURATION := 3.0
const RECOVER_FROM_BURNT := 1.0

@onready var trunk: ColorRect = $Trunk
@onready var crown: Polygon2D = $Crown
@onready var fire: Polygon2D = $Fire

var stage: Stage = Stage.SPROUT
var state: State = State.ALIVE
var water: float = 0.0
var burn_timer: float = 0.0


func setup_initial(initial_stage: Stage, initial_water: float = 0.0) -> void:
	stage = initial_stage
	water = initial_water
	state = State.ALIVE
	_update_visual()


func _ready() -> void:
	z_index = int(global_position.x) % 1000 + 1
	_update_visual()


func apply_rain(amount: float) -> void:
	match state:
		State.ALIVE:
			water += amount
			_try_grow()
		State.BURNING:
			burn_timer -= amount * 2.5
			if burn_timer <= 0.0:
				state = State.ALIVE
				burn_timer = 0.0
		State.BURNT:
			water += amount
			if water >= RECOVER_FROM_BURNT:
				state = State.ALIVE
				stage = Stage.SPROUT
				water = 0.0
	_update_visual()


func _try_grow() -> void:
	if stage >= Stage.ANCIENT:
		return
	var threshold: float = STAGE_THRESHOLDS[stage]
	if water < threshold:
		return
	water -= threshold
	stage = (mini(stage + 1, Stage.ANCIENT)) as Stage
	_try_grow()


func ignite() -> void:
	if state != State.ALIVE:
		return
	if stage >= Stage.SPROUT:
		state = State.BURNING
		burn_timer = BURN_DURATION
		_update_visual()


func can_be_struck() -> bool:
	return state == State.ALIVE and stage >= Stage.SPROUT


func _process(delta: float) -> void:
	if state != State.BURNING:
		return

	burn_timer -= delta
	if burn_timer <= 0.0:
		state = State.BURNT
		water = 0.0
		_update_visual()
	else:
		_update_fire_visual()


func _water_color() -> Color:
	var threshold: float = STAGE_THRESHOLDS.get(stage, 1.0)
	var saturation := clampf(water / threshold, 0.0, 1.0)
	var dry := Color(0.55, 0.42, 0.2)
	var lush := Color(0.08, 0.62, 0.14)
	return dry.lerp(lush, saturation)


func _stage_metrics() -> Dictionary:
	match stage:
		Stage.SPROUT:
			return {"trunk": Vector2(4, 10), "trunk_pos": Vector2(-2, -10), "crown_h": 16.0, "crown_w": 10.0}
		Stage.SAPLING:
			return {"trunk": Vector2(6, 16), "trunk_pos": Vector2(-3, -16), "crown_h": 24.0, "crown_w": 14.0}
		Stage.YOUNG:
			return {"trunk": Vector2(8, 22), "trunk_pos": Vector2(-4, -22), "crown_h": 34.0, "crown_w": 20.0}
		Stage.MATURE:
			return {"trunk": Vector2(10, 30), "trunk_pos": Vector2(-5, -30), "crown_h": 46.0, "crown_w": 26.0}
		Stage.ANCIENT:
			return {"trunk": Vector2(12, 38), "trunk_pos": Vector2(-6, -38), "crown_h": 58.0, "crown_w": 32.0}
		_:
			return {"trunk": Vector2(4, 10), "trunk_pos": Vector2(-2, -10), "crown_h": 16.0, "crown_w": 10.0}


func _update_visual() -> void:
	if state == State.BURNT:
		trunk.visible = true
		trunk.size = Vector2(8, 10)
		trunk.position = Vector2(-4, -10)
		trunk.color = Color(0.15, 0.15, 0.15)
		crown.visible = false
		fire.visible = false
		return

	var metrics := _stage_metrics()
	var crown_color := _water_color()

	trunk.visible = true
	trunk.size = metrics["trunk"]
	trunk.position = metrics["trunk_pos"]
	trunk.color = Color(0.38, 0.24, 0.12)

	crown.visible = true
	crown.color = crown_color
	var ch: float = metrics["crown_h"]
	var cw: float = metrics["crown_w"]
	crown.polygon = PackedVector2Array([
		Vector2(0, -ch),
		Vector2(cw, -ch * 0.35),
		Vector2(0, -ch * 0.15),
		Vector2(-cw, -ch * 0.35),
	])

	if state == State.BURNING:
		crown.color = Color(0.4, 0.15, 0.05)
		_update_fire_visual()
	else:
		fire.visible = false


func _update_fire_visual() -> void:
	fire.visible = true
	var metrics := _stage_metrics()
	var ch: float = metrics["crown_h"]
	var flicker := 1.0 + sin(Time.get_ticks_msec() * 0.02) * 0.15
	fire.color = Color(1.0, 0.45, 0.05, 0.9)
	fire.polygon = PackedVector2Array([
		Vector2(0, -(ch + 12.0) * flicker),
		Vector2(14.0 * flicker, -(ch * 0.5)),
		Vector2(0, -(ch * 0.3)),
		Vector2(-14.0 * flicker, -(ch * 0.5)),
	])
