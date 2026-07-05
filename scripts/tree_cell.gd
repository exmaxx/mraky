class_name TreeCell
extends Area2D

enum State { EMPTY, GROWING, MATURE, BURNING, BURNT }

const GROWTH_TO_SPROUT := 1.0
const GROWTH_TO_MATURE := 1.0
const BURN_DURATION := 3.0
const RECOVER_FROM_BURNT := 0.8

@onready var ground: ColorRect = $Ground
@onready var trunk: ColorRect = $Trunk
@onready var crown: Polygon2D = $Crown
@onready var fire: Polygon2D = $Fire

var state: State = State.EMPTY
var growth: float = 0.0
var burn_timer: float = 0.0


func setup_initial(initial_state: State) -> void:
	state = initial_state
	match state:
		State.GROWING:
			growth = 0.5
		State.MATURE:
			growth = 1.0
		_:
			growth = 0.0
	_update_visual()


func _ready() -> void:
	_update_visual()


func apply_rain(amount: float) -> void:
	match state:
		State.EMPTY:
			growth += amount
			if growth >= GROWTH_TO_SPROUT:
				state = State.GROWING
				growth = 0.0
		State.GROWING:
			growth += amount
			if growth >= GROWTH_TO_MATURE:
				state = State.MATURE
				growth = 1.0
		State.BURNING:
			burn_timer -= amount * 2.5
			if burn_timer <= 0.0:
				state = State.MATURE
				burn_timer = 0.0
		State.BURNT:
			growth += amount
			if growth >= RECOVER_FROM_BURNT:
				state = State.EMPTY
				growth = 0.0
	_update_visual()


func ignite() -> void:
	if state == State.GROWING or state == State.MATURE:
		state = State.BURNING
		burn_timer = BURN_DURATION
		_update_visual()


func can_be_struck() -> bool:
	return state == State.GROWING or state == State.MATURE


func _process(delta: float) -> void:
	if state != State.BURNING:
		return

	burn_timer -= delta
	if burn_timer <= 0.0:
		state = State.BURNT
		growth = 0.0
		_update_visual()
	else:
		_update_fire_visual()


func _update_visual() -> void:
	match state:
		State.EMPTY:
			ground.color = Color(0.45, 0.32, 0.18)
			trunk.visible = false
			crown.visible = false
			fire.visible = false
		State.GROWING:
			ground.color = Color(0.35, 0.55, 0.22)
			trunk.visible = true
			trunk.size = Vector2(6, 14)
			trunk.position = Vector2(-3, -14)
			trunk.color = Color(0.4, 0.25, 0.12)
			crown.visible = true
			crown.color = Color(0.2, 0.65, 0.25)
			crown.polygon = PackedVector2Array([
				Vector2(0, -28), Vector2(12, -12), Vector2(0, -8), Vector2(-12, -12)
			])
			fire.visible = false
		State.MATURE:
			ground.color = Color(0.28, 0.5, 0.18)
			trunk.visible = true
			trunk.size = Vector2(10, 24)
			trunk.position = Vector2(-5, -24)
			trunk.color = Color(0.35, 0.2, 0.1)
			crown.visible = true
			crown.color = Color(0.1, 0.55, 0.15)
			crown.polygon = PackedVector2Array([
				Vector2(0, -48), Vector2(22, -18), Vector2(0, -10), Vector2(-22, -18)
			])
			fire.visible = false
		State.BURNING:
			ground.color = Color(0.35, 0.2, 0.1)
			trunk.visible = true
			trunk.color = Color(0.25, 0.12, 0.05)
			crown.visible = true
			crown.color = Color(0.4, 0.15, 0.05)
			_update_fire_visual()
		State.BURNT:
			ground.color = Color(0.2, 0.2, 0.2)
			trunk.visible = true
			trunk.size = Vector2(8, 10)
			trunk.position = Vector2(-4, -10)
			trunk.color = Color(0.15, 0.15, 0.15)
			crown.visible = false
			fire.visible = false


func _update_fire_visual() -> void:
	fire.visible = true
	var flicker := 1.0 + sin(Time.get_ticks_msec() * 0.02) * 0.15
	fire.color = Color(1.0, 0.45, 0.05, 0.9)
	fire.polygon = PackedVector2Array([
		Vector2(0, -58 * flicker),
		Vector2(14 * flicker, -30),
		Vector2(0, -22),
		Vector2(-14 * flicker, -30),
	])
