extends Node
class_name CardVisuals

var card: Node2D

func init(parent: Node2D) -> void:
	card = parent
	
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

func play_hit_animation(amount: int) -> void:
	var sprite = get_sprite()
	var origin = sprite.position
	var mat = get_material()

	var punch = clamp(amount * 2.0, 4.0, 20.0)
	var scale_punch = clamp(0.2 + amount * 0.006, 0.2, 0.28)

	var punch_tween = card.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	punch_tween.tween_property(sprite, "position", origin + Vector2(punch, 0), 0.05)
	punch_tween.tween_property(sprite, "scale", Vector2(scale_punch, scale_punch), 0.05)
	punch_tween.tween_property(sprite, "position", origin, 0.3)
	punch_tween.tween_property(sprite, "scale", Vector2(0.2, 0.2), 0.3)
	
	if mat:
		mat.set_shader_parameter("flash_color", Color(1.0, 0.0, 0.0, 0.8))
		var flash_tween = card.create_tween()
		flash_tween.tween_method(
			func(val: float): mat.set_shader_parameter("flash_color", Color(1.0, 0.0, 0.0, val)),
			0.8, 0.0, 0.4
		)

	spawn_damage_number(amount)

func spawn_damage_number(amount: int) -> void:
	var label = Label.new()
	label.text = str(amount)
	label.add_theme_font_size_override("font_size", clamp(16 + amount * 3, 20, 42))

	if amount >= 3:
		label.modulate = Color(1.0, 0.2, 0.2)
	elif amount >= 2:
		label.modulate = Color(1.0, 0.6, 0.0)
	else:
		label.modulate = Color(1.0, 1.0, 0.2)

	var scene_root = card.get_tree().current_scene
	scene_root.add_child(label)
	label.global_position = card.global_position + Vector2(randf_range(-15, 15), -60)

	var tween = card.create_tween().set_parallel(true)
	tween.tween_property(label, "global_position", label.global_position + Vector2(randf_range(-10, 10), -55), 0.7)
	tween.tween_property(label, "modulate:a", 0.0, 0.6).set_delay(0.2)
	tween.tween_callback(label.queue_free).set_delay(0.75)
	

func play_block_animation() -> void:
	var sprite = get_sprite()
	var mat = get_material()
	
	var origin_scale = sprite.scale
	var block_tween = card.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	block_tween.tween_property(sprite, "scale", origin_scale * 1.12, 0.06)
	block_tween.tween_property(sprite, "scale", origin_scale, 0.25)
	
	if mat:
		mat.set_shader_parameter("flash_color", Color(0.6, 0.85, 1.0, 1.0))
		var flash_tween = card.create_tween()
		flash_tween.tween_method(
			func(val: float): mat.set_shader_parameter("flash_color", Color(0.6, 0.85, 1.0, val)),
			1.0, 0.0, 0.35
		)
		
	_spawn_status_text("BLOCK", Color(0.5, 0.85, 1.0))

func play_poison_apply_animation() -> void:
	var sprite = get_sprite()
	var mat = get_material()

	var origin_rot = sprite.rotation
	var wobble = card.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	wobble.tween_property(sprite, "rotation", origin_rot - 0.12, 0.08)
	wobble.tween_property(sprite, "rotation", origin_rot + 0.10, 0.10)
	wobble.tween_property(sprite, "rotation", origin_rot, 0.12)
	
	if mat:
		mat.set_shader_parameter("flash_color", Color(0.1, 1.0, 0.25, 0.9))
		var flash_tween = card.create_tween()
		flash_tween.tween_method(
			func(val: float): mat.set_shader_parameter("flash_color", Color(0.1, 1.0, 0.25, val)),
			0.9, 0.0, 0.5
		)

	_spawn_status_text("POISON", Color(0.2, 1.0, 0.3))

func play_poison_tick_animation(stacks: int) -> void:
	var sprite = get_sprite()
	var mat = get_material()
	var origin_scale = sprite.scale
	
	var swell = card.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	swell.tween_property(sprite, "scale", origin_scale * 1.08, 0.12)
	swell.tween_property(sprite, "scale", origin_scale, 0.22)
	
	if mat:
		mat.set_shader_parameter("flash_color", Color(0.05, 0.85, 0.2, 0.6))
		var flash_tween = card.create_tween()
		flash_tween.tween_method(
			func(val: float): mat.set_shader_parameter("flash_color", Color(0.05, 0.85, 0.2, val)),
			0.6, 0.0, 0.45
		)

	_spawn_damage_number_colored(stacks, Color(0.2, 1.0, 0.3))

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

func _spawn_damage_number_colored(amount: int, color: Color) -> void:
	var label = Label.new()
	label.text = "-%d" % amount
	label.add_theme_font_size_override("font_size", clamp(16 + amount * 3, 18, 36))
	label.modulate = color
	var scene_root = card.get_tree().current_scene
	scene_root.add_child(label)
	label.global_position = card.global_position + Vector2(randf_range(-15, 15), -60)

	var tween = card.create_tween().set_parallel(true)
	tween.tween_property(label, "global_position", label.global_position + Vector2(randf_range(-10, 10), -50), 0.7)
	tween.tween_property(label, "modulate:a", 0.0, 0.6).set_delay(0.2)
	tween.tween_callback(label.queue_free).set_delay(0.75)

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
