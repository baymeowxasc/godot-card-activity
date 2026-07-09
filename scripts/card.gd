extends Node2D

var mouse_in: bool = false
var is_dragging: bool = false
var is_snapped: bool = false
var snap_target: Vector2 = Vector2.ZERO
var hand_index: int = -1
var hand_position: Vector2 = Vector2.ZERO 

var current_slot: Node2D = null 

func _ready() -> void:
	add_to_group("cards")
	var hand = get_tree().get_first_node_in_group("hand")
	hand.add_card(self)

func set_hand_position(pos: Vector2, index: int) -> void:
	hand_index = index
	hand_position = pos  
	snap_to(pos)

func snap_to(pos: Vector2) -> void:
	is_snapped = true
	snap_target = pos
	is_dragging = false
	if Mousebrain.node_being_dragged == self:
		Mousebrain.node_being_dragged = null

func release_snap() -> void:
	is_snapped = false

func return_to_hand() -> void:
	snap_to(hand_position)

func _physics_process(delta: float) -> void:
	drag_logic(delta)

func drag_logic(delta: float) -> void:
	_update_shadow()

	if is_dragging:
		_update_drag_position(delta)
	elif is_snapped:
		_update_snap_position(delta)

	_handle_mouse_input(delta)
	_update_scale_and_zindex(delta)

func _update_shadow() -> void:
	$Sprite2D/shadow.position = Vector2(-12, 12).rotated($Sprite2D.rotation)

func _update_drag_position(delta: float) -> void:
	var target_pos = get_global_mouse_position()
	var screen_size = get_viewport_rect().size
	var half_w = $Sprite2D.texture.get_width() * $Sprite2D.scale.x * 0.5
	var half_h = $Sprite2D.texture.get_height() * $Sprite2D.scale.y * 0.5
	target_pos.x = clamp(target_pos.x, half_w, screen_size.x - half_w)
	target_pos.y = clamp(target_pos.y, half_h, screen_size.y - half_h)
	global_position = lerp(global_position, target_pos, 22.0 * delta)

func _update_snap_position(delta: float) -> void:
	global_position = lerp(global_position, snap_target, 18.0 * delta)
	$Sprite2D.rotation_degrees = lerp($Sprite2D.rotation_degrees, 0.0, 12.0 * delta)

func _handle_mouse_input(delta: float) -> void:
	if current_slot != null:
		return
	if (mouse_in or is_dragging) and (Mousebrain.node_being_dragged == null or Mousebrain.node_being_dragged == self):
		if Input.is_action_pressed("click"):
			_start_drag(delta)
		else:
			_stop_drag()

func _start_drag(delta: float) -> void:
	is_dragging = true
	is_snapped = false
	Mousebrain.node_being_dragged = self
	_set_rotation(delta)
	$Sprite2D.z_index = 100

	if current_slot != null:
		current_slot.is_occupied = false
		current_slot.occupant = null
		current_slot = null
		var hand = get_tree().get_first_node_in_group("hand")
		hand.add_card(self)

func _stop_drag() -> void:
	if is_dragging:
		return_to_hand()
	is_dragging = false
	if Mousebrain.node_being_dragged == self:
		Mousebrain.node_being_dragged = null

func _update_scale_and_zindex(_delta: float) -> void:
	if is_dragging:
		_change_scale(Vector2(0.26, 0.26))
	elif mouse_in and Mousebrain.node_being_dragged == null and current_slot == null:
		_change_scale(Vector2(0.24, 0.24))
		$Sprite2D.z_index = 430
	else:
		_change_scale(Vector2(0.2, 0.2))
		if not is_dragging:
			$Sprite2D.z_index = 0

func _on_area_2d_mouse_entered() -> void:
	mouse_in = true

func _on_area_2d_mouse_exited() -> void:
	mouse_in = false
	if not is_dragging:
		$Sprite2D.z_index = 0
		_change_scale(Vector2(0.2, 0.2))

var current_goal_scale: Vector2 = Vector2(0.2, 0.2)
var scale_tween: Tween
func _change_scale(desired_scale: Vector2) -> void:
	if desired_scale == current_goal_scale:
		return
	if scale_tween:
		scale_tween.kill()
	scale_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	scale_tween.tween_property($Sprite2D, "scale", desired_scale, 0.125)
	current_goal_scale = desired_scale

var last_pos: Vector2
var max_card_rotation: float = 12.5
func _set_rotation(delta: float) -> void:
	var desired_rotation: float = clamp((global_position - last_pos).x * 0.85, -max_card_rotation, max_card_rotation)
	$Sprite2D.rotation_degrees = lerp($Sprite2D.rotation_degrees, desired_rotation, 12.0 * delta)
	last_pos = global_position
	
var card_data: CardData = null

func setup(data: CardData) -> void:
	card_data = data
	if data.back_texture:
		$Sprite2D.texture = data.back_texture
	$Sprite2D.scale = Vector2(0.2, 0.2)

func play_draw_animation(deck_pos: Vector2, hand_pos: Vector2) -> void:
	global_position = deck_pos
	is_snapped = false

	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

	tween.tween_property(self, "global_position", hand_pos, 0.35)
	tween.tween_property($Sprite2D, "scale", Vector2(0.0, 0.2), 0.15)
	tween.tween_callback(func():
		if card_data.front_texture:
			$Sprite2D.texture = card_data.front_texture
	)
	tween.tween_property($Sprite2D, "scale", Vector2(0.2, 0.2), 0.15)
