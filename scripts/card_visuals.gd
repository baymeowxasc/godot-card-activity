extends Node
class_name CardVisuals

var card: Node2D

func init(parent: Node2D) -> void:
	card = parent
	
func get_sprite() -> Sprite2D:
	return card.get_node("Sprite2D")

func get_material() -> ShaderMaterial:
	return get_sprite().material as ShaderMaterial

func play_draw_animation(deck_pos: Vector2, hand_pos: Vector2) -> void:
	card.global_position = deck_pos
	card.drag.is_snapped = false
	var tween = card.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(card, "global_position", hand_pos, 0.35)
	tween.tween_property(get_sprite(), "scale", Vector2(0.0, 0.2), 0.15)
	tween.tween_callback(func():
		if card.card_data and card.card_data.front_texture:
			get_sprite().texture = card.card_data.front_texture
	)
	tween.tween_property(get_sprite(), "scale", Vector2(0.2, 0.2), 0.15)

func play_hit_animation() -> void:
	var origin = get_sprite().position
	var tween = card.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(get_sprite(), "position", origin + Vector2(8, 0), 0.05)
	tween.tween_property(get_sprite(), "position", origin, 0.3)

func dissolve(on_complete: Callable) -> void:
	var mat = get_material()
	if mat == null:
		on_complete.call()
		return
	var tween = card.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	tween.tween_method(func(val: float): mat.set_shader_parameter("dissolve_value", val), 1.0, 0.0, 1.2)
	tween.tween_callback(on_complete)

func reappear() -> void:
	var mat = get_material()
	if mat == null:
		return
	mat.set_shader_parameter("dissolve_value", 0.0)
	var tween = card.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_method(func(val: float): mat.set_shader_parameter("dissolve_value", val), 0.0, 1.0, 1.2)
