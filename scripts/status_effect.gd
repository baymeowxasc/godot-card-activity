extends Node
class_name StatusEffect

var card: Node2D
var block_charges: int = 0  
var poison_stacks: int = 0   

var _block_label: Label = null
var _poison_label: Label = null

func setup(parent: Node2D) -> void:
	card = parent

func has_block() -> bool:
	return block_charges > 0

func add_block(charges: int = 1) -> void:
	block_charges += charges
	_block_label = _ensure_status_label(_block_label, "🛡", Color(0.4, 0.7, 1.0), Vector2(10, 58))
	_refresh_label(_block_label, "🛡", block_charges)
	_animate_icon_appear(_block_label)

func consume_block() -> void:
	block_charges = maxi(block_charges - 1, 0)
	if block_charges <= 0:
		card.visuals.break_shield()
		_animate_icon_disappear(_block_label)
	else:
		card.visuals.play_block_animation()
		_refresh_label(_block_label, "🛡", block_charges)

func add_poison(stacks: int = 1) -> void:
	poison_stacks += stacks
	_poison_label = _ensure_status_label(_poison_label, "☠", Color(0.2, 0.9, 0.2), Vector2(10, 88))
	_refresh_label(_poison_label, "☠", poison_stacks)
	card.visuals.play_poison_apply_animation()
	_animate_icon_appear(_poison_label)

func tick_poison(dmg: int = -1) -> void:
	if poison_stacks <= 0:
		return
	var actual_dmg = dmg if dmg > 0 else poison_stacks
	card.visuals.play_poison_tick_animation(actual_dmg)
	poison_stacks = maxi(poison_stacks - 1, 0)
	if poison_stacks <= 0:
		_animate_icon_disappear(_poison_label)
	else:
		_refresh_label(_poison_label, "☠", poison_stacks)

func _ensure_status_label(label: Label, icon: String, color: Color, offset: Vector2) -> Label:
	if label != null:
		return label
	var l = _make_icon_label(icon, color)
	card.add_child(l)
	l.position = offset
	return l

func _make_icon_label(icon: String, color: Color) -> Label:
	var label := Label.new()
	label.text = icon
	label.add_theme_font_size_override("font_size", 22)
	label.modulate = color
	label.modulate.a = 0.0
	label.z_index = 20
	return label

func _refresh_label(label: Label, icon: String, count: int) -> void:
	if label:
		label.text = icon if count == 1 else "%sx%d" % [icon, count]

func _animate_icon_appear(label: Label) -> void:
	if label == null:
		return
	label.scale = Vector2(0.5, 0.5)
	label.modulate.a = 0.0
	var tween := card.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.25)
	tween.tween_property(label, "modulate:a", 1.0, 0.2)

func clear() -> void:
	block_charges = 0
	poison_stacks = 0
	if _block_label:
		_block_label.queue_free()
		_block_label = null
	if _poison_label:
		_poison_label.queue_free()
		_poison_label = null

func _animate_icon_disappear(label: Label) -> void:
	if label == null:
		return
	var tween := card.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)
	tween.tween_property(label, "scale", Vector2(0.3, 0.3), 0.2)
	tween.tween_property(label, "modulate:a", 0.0, 0.2)
	tween.chain().tween_callback(label.queue_free)
	if label == _block_label:
		_block_label = null
	elif label == _poison_label:
		_poison_label = null
