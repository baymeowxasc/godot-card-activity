extends Node
class_name CardVisuals

var card: Node2D
var _anim: AnimationPlayer

func init(parent: Node2D) -> void:
	card = parent
	_anim = parent.get_node("AnimationPlayer")
	
func get_sprite() -> Sprite2D:
	return card.get_node("Sprite2D")

func get_material() -> ShaderMaterial:
	return get_sprite().material as ShaderMaterial
	
func get_health_label() -> Label:
	return card.get_node("HealthLabel")

func play_draw_animation(deck_pos: Vector2, hand_pos: Vector2) -> void:
	card.is_drawing = true
	card.global_position = deck_pos
	card.drag.is_snapped = false
	get_health_label().visible = false  

	var tween = card.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(card, "global_position", hand_pos, 0.35)
	tween.tween_property(get_sprite(), "scale", Vector2(0.0, 0.2), 0.15)
	tween.tween_callback(func():
		if card.card_data and card.card_data.front_texture:
			get_sprite().texture = card.card_data.front_texture
	)
	tween.tween_property(get_sprite(), "scale", Vector2(0.2, 0.2), 0.15)
	tween.tween_callback(func():
		get_health_label().visible = true  
		card.is_drawing = false
		if card.status._block_label:
			card.status._block_label.visible = true
		if card.status._poison_label:
			card.status._poison_label.visible = true
	)

func spawn_damage_number(amount: int, color: Color = Color.WHITE, prefix: String = "") -> void:
	var label = Label.new()
	label.text = prefix + str(amount)
	label.add_theme_font_size_override("font_size", clamp(16 + amount * 3, 18, 42))

	if color == Color.WHITE:
		if amount >= 3:
			label.modulate = Color(1.0, 0.2, 0.2)
		elif amount >= 2:
			label.modulate = Color(1.0, 0.6, 0.0)
		else:
			label.modulate = Color(1.0, 1.0, 0.2)
	else:
		label.modulate = color

	var scene_root = card.get_tree().current_scene
	scene_root.add_child(label)
	label.global_position = card.global_position + Vector2(randf_range(-15, 15), -60)

	var tween = card.create_tween().set_parallel(true)
	tween.tween_property(label, "global_position", label.global_position + Vector2(randf_range(-10, 10), -52), 0.7)
	tween.tween_property(label, "modulate:a", 0.0, 0.6).set_delay(0.2)
	tween.tween_callback(label.queue_free).set_delay(0.75)
	
func _flash(color: Color, intensity: float, duration: float) -> void:
	var mat = get_material()
	if not mat:
		return
	mat.set_shader_parameter("flash_color", Color(color.r, color.g, color.b, intensity))
	var tween = card.create_tween()
	tween.tween_method(
		func(val: float): mat.set_shader_parameter("flash_color", Color(color.r, color.g, color.b, val)),
		intensity, 0.0, duration
	)

func play_hit_animation(amount: int) -> void:
	_anim.play("hit")         
	_flash(Color(1.0, 0.0, 0.0), 0.8, 0.4)
	spawn_damage_number(amount)

func play_block_animation() -> void:
	_anim.play("block")       
	_flash(Color(0.6, 0.85, 1.0), 1.0, 0.35)
	_spawn_status_text("BLOCK", Color(0.5, 0.85, 1.0))

func play_poison_apply_animation() -> void:
	_anim.play("poison_apply") 
	_flash(Color(0.1, 1.0, 0.25), 0.9, 0.5)
	_spawn_status_text("POISON", Color(0.2, 1.0, 0.3))

func play_poison_tick_animation(stacks: int) -> void:
	_anim.play("poison_tick")  
	_flash(Color(0.05, 0.85, 0.2), 0.6, 0.45)
	spawn_damage_number(stacks, Color(0.2, 1.0, 0.3), "-")

func _spawn_status_text(text: String, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label.modulate = color
	var scene_root = card.get_tree().current_scene
	scene_root.add_child(label)
	label.global_position = card.global_position + Vector2(randf_range(-20, 20), -72)

	var tween = card.create_tween().set_parallel(true)
	tween.tween_property(label, "global_position", label.global_position + Vector2(randf_range(-8, 8), -38), 0.65)
	tween.tween_property(label, "modulate:a", 0.0, 0.55).set_delay(0.15)
	tween.tween_callback(label.queue_free).set_delay(0.7)

func dissolve(on_complete: Callable) -> void:
	card.status.clear()
	card.set_health_label_visible(false)
	var mat = get_material()
	if mat == null:
		on_complete.call()
		return
	var tween = card.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	tween.tween_method(func(val: float): mat.set_shader_parameter("dissolve_value", val), 1.0, 0.0, 1.2)
	tween.tween_callback(on_complete)

func reappear() -> void:
	get_sprite().scale = Vector2(0.2, 0.2)
	var mat = get_material()
	if mat == null:
		return
	mat.set_shader_parameter("dissolve_value", 0.0)
	var tween = card.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_method(func(val: float): mat.set_shader_parameter("dissolve_value", val), 0.0, 1.0, 1.2)

func break_shield() -> void:
	var fx_scene = preload("res://scenes/shield_break_fx.tscn")
	var fx = fx_scene.instantiate()
	card.get_tree().current_scene.add_child(fx)
	fx.play()
