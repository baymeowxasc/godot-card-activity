extends Node
class_name CardDrag

var card: Node2D
var _sprite: Sprite2D
var _shadow: Node2D
var mouse_in: bool = false
var is_dragging: bool = false
var is_snapped: bool = false
var snap_target: Vector2 = Vector2.ZERO
var hand_index: int = -1
var hand_position: Vector2 = Vector2.ZERO
var last_pos: Vector2
var max_card_rotation: float = 12.5
var current_goal_scale: Vector2 = Vector2(0.2, 0.2)
var scale_tween: Tween

func init(parent: Node2D) -> void:
	card = parent
	_sprite = parent.get_node("Sprite2D")
	_shadow = parent.get_node("Sprite2D/shadow")

func snap_to(pos: Vector2) -> void:
	is_snapped = true
	snap_target = pos
	is_dragging = false
	if Mousebrain.node_being_dragged == card:
		Mousebrain.node_being_dragged = null

func return_to_hand() -> void:
	snap_to(hand_position)

func set_hand_position(pos: Vector2, index: int) -> void:
	hand_index = index
	hand_position = pos
	snap_to(pos)

func process(delta: float) -> void:
	_shadow.position = Vector2(-12, 12).rotated(_sprite.rotation)
	if is_dragging:
		_update_drag_position(delta)
	elif is_snapped:
		_update_snap_position(delta)
	_handle_mouse_input(delta)
	_update_scale_and_zindex(delta)

func _update_drag_position(delta: float) -> void:
	var target_pos = card.get_global_mouse_position()
	var screen_size = card.get_viewport_rect().size
	var half = Vector2(
		_sprite.texture.get_width() * _sprite.scale.x,
		_sprite.texture.get_height() * _sprite.scale.y
	) * 0.5
	target_pos = target_pos.clamp(half, screen_size - half)
	card.global_position = lerp(card.global_position, target_pos, 22.0 * delta)

func _update_snap_position(delta: float) -> void:
	card.global_position = lerp(card.global_position, snap_target, 18.0 * delta)
	_sprite.rotation_degrees = lerp(_sprite.rotation_degrees, 0.0, 12.0 * delta)

func _handle_mouse_input(delta: float) -> void:
	if card.current_slot != null:
		return
	if (mouse_in or is_dragging) and (Mousebrain.node_being_dragged == null or Mousebrain.node_being_dragged == card):
		if Input.is_action_pressed("click"):
			_start_drag(delta)
		else:
			_stop_drag()

func _start_drag(delta: float) -> void:
	is_dragging = true
	is_snapped = false
	Mousebrain.node_being_dragged = card
	_set_rotation(delta)
	_sprite.z_index = 100
	if card.current_slot != null:
		card.current_slot.on_card_removed()
		card.current_slot = null
		var hand = card.get_tree().get_first_node_in_group("hand")
		hand.add_card(card)

func _stop_drag() -> void:
	if is_dragging:
		return_to_hand()
	is_dragging = false
	if Mousebrain.node_being_dragged == card:
		Mousebrain.node_being_dragged = null

func _set_rotation(delta: float) -> void:
	var desired = clamp((card.global_position - last_pos).x * 0.85, -max_card_rotation, max_card_rotation)
	_sprite.rotation_degrees = lerp(_sprite.rotation_degrees, desired, 12.0 * delta)
	last_pos = card.global_position

func _update_scale_and_zindex(_delta: float) -> void:
	if is_dragging:
		change_scale(Vector2(0.26, 0.26))
	elif mouse_in and Mousebrain.node_being_dragged == null and card.current_slot == null:
		change_scale(Vector2(0.24, 0.24))
		_sprite.z_index = 430
	else:
		change_scale(Vector2(0.2, 0.2))
		if not is_dragging:
			_sprite.z_index = 0

func change_scale(desired: Vector2) -> void:
	if desired == current_goal_scale:
		return
	if scale_tween:
		scale_tween.kill()
	scale_tween = card.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	scale_tween.tween_property(_sprite, "scale", desired, 0.125)
	current_goal_scale = desired
