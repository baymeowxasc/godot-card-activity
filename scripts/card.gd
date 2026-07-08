extends Control

# ── Data ──────────────────────────────────────────────────────────────────────
@export var card_data: CardData   # assign in editor or at runtime

# ── State machine ─────────────────────────────────────────────────────────────
enum State { IN_DECK, IN_HAND, DRAGGING, ON_FIELD, ACTIVATING, DEAD }
var state: State = State.IN_DECK

# ── Signals ───────────────────────────────────────────────────────────────────
signal card_dropped(card: Control, world_pos: Vector2)
signal card_activated(card: Control)
signal card_sent_to_grave(card: Control)

# ── Node refs ─────────────────────────────────────────────────────────────────
@onready var sprite     : Sprite2D        = $Sprite2D
@onready var shadow     : Sprite2D        = $Sprite2D/shadow
@onready var anim       : AnimationPlayer = $AnimationPlayer
@onready var drop_area  : Area2D          = $Area2D

# ── Drag internals ────────────────────────────────────────────────────────────
var last_pos        : Vector2
var scale_tween     : Tween
var goal_scale      : Vector2 = Vector2(0.2, 0.2)

const MAX_ROT       : float = 12.5
const SCALE_DEFAULT := Vector2(0.2,  0.2)
const SCALE_HOVER   := Vector2(0.22, 0.22)
const SCALE_DRAG    := Vector2(0.26, 0.26)

# ──────────────────────────────────────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	match state:
		State.IN_HAND:   _process_hand(delta)
		State.DRAGGING:  _process_drag(delta)
		_:               pass   # other states don't move

# ── Hand hover (mouse over, not held) ─────────────────────────────────────────
func _process_hand(delta: float) -> void:
	shadow.position = Vector2(-12, 12).rotated(sprite.rotation)
	sprite.rotation_degrees = lerp(sprite.rotation_degrees, 0.0, 22.0 * delta)
	_change_scale(SCALE_DEFAULT)

func _on_mouse_entered() -> void:
	if state == State.IN_HAND:
		_change_scale(SCALE_HOVER)

func _on_mouse_exited() -> void:
	if state == State.IN_HAND:
		_change_scale(SCALE_DEFAULT)

# ── Drag ──────────────────────────────────────────────────────────────────────
func _process_drag(delta: float) -> void:
	shadow.position = Vector2(-12, 12).rotated(sprite.rotation)
	global_position = lerp(
		global_position,
		get_global_mouse_position() - size / 2.0,
		22.0 * delta
	)
	_change_scale(SCALE_DRAG)
	_set_rotation(delta)
	sprite.z_index = 100

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and state == State.IN_HAND:
			_begin_drag()
		elif not event.pressed and state == State.DRAGGING:
			_end_drag()

func _begin_drag() -> void:
	if Mousebrain.node_being_dragged != null:
		return
	state = State.DRAGGING
	Mousebrain.node_being_dragged = self

func _end_drag() -> void:
	state = State.IN_HAND
	Mousebrain.node_being_dragged = null
	sprite.z_index = 0
	emit_signal("card_dropped", self, global_position)

# ── Animations (called externally by GameBoard / CardZone) ────────────────────
func play_flip() -> void:
	# AnimationPlayer "flip" track: scale.x 1→0→1 with texture swap at midpoint
	anim.play("flip")
	await anim.animation_finished

func play_damage() -> void:
	anim.play("damage")   # shake: position offset keyframes, red flash on modulate
	await anim.animation_finished

func play_activate() -> void:
	state = State.ACTIVATING
	anim.play("activate") # glow, scale pulse, effect callback mid-animation
	await anim.animation_finished
	state = State.ON_FIELD

func play_to_grave() -> void:
	state = State.DEAD
	anim.play("to_grave") # spin + shrink + fade
	await anim.animation_finished
	emit_signal("card_sent_to_grave", self)
	queue_free()

# ── Public API (called by CardZone when snapping) ─────────────────────────────
func place_on_field(slot_pos: Vector2) -> void:
	state = State.ON_FIELD
	create_tween().tween_property(self, "global_position", slot_pos, 0.18)
	_change_scale(SCALE_DEFAULT)

func return_to_hand(hand_pos: Vector2) -> void:
	state = State.IN_HAND
	create_tween().tween_property(self, "global_position", hand_pos, 0.18)
	_change_scale(SCALE_DEFAULT)

# ── Helpers (unchanged from your version) ─────────────────────────────────────
func _change_scale(desired: Vector2) -> void:
	if desired == goal_scale: return
	if scale_tween: scale_tween.kill()
	scale_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	scale_tween.tween_property(sprite, "scale", desired, 0.125)
	goal_scale = desired

func _set_rotation(delta: float) -> void:
	var desired: float = clamp((global_position - last_pos).x * 0.85, -MAX_ROT, MAX_ROT)
	sprite.rotation_degrees = lerp(sprite.rotation_degrees, desired, 12.0 * delta)
	last_pos = global_position

# add these to card.gd
var current_zone: CardZone = null   # set by CardZone when accepted

func set_state(new_state: State) -> void:
	state = new_state

func face_up() -> void:
	sprite.texture = card_data.art

func face_down() -> void:
	sprite.texture = card_data.back
