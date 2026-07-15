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
	_ensure_block_label()
	_refresh_block_label()
	_animate_icon_appear(_block_label)

func consume_block() -> void:
	block_charges = maxi(block_charges - 1, 0)
	card.visuals.play_block_animation()
	if block_charges <= 0:
		_animate_icon_disappear(_block_label)
	else:
		_refresh_block_label()

func add_poison(stacks: int = 1) -> void:
	poison_stacks += stacks
	_ensure_poison_label()
	_refresh_poison_label()
	card.visuals.play_poison_apply_animation()
	_animate_icon_appear(_poison_label)

func tick_poison() -> void:
	if poison_stacks <= 0:
		return
	card.visuals.play_poison_tick_animation(poison_stacks)
	poison_stacks = maxi(poison_stacks - 1, 0)  
	if poison_stacks <= 0:
		_animate_icon_disappear(_poison_label)
	else:
		_refresh_poison_label()

func _ensure_block_label() -> void:
	if _block_label != null:
		return
	_block_label = _make_icon_label("🛡", Color(0.4, 0.7, 1.0))
	card.add_child(_block_label)
	_block_label.position = Vector2(-18, -52)   

func _ensure_poison_label() -> void:
	if _poison_label != null:
		return
	_poison_label = _make_icon_label("☠", Color(0.2, 0.9, 0.2))
	card.add_child(_poison_label)
	_poison_label.position = Vector2(4, -52)   

func _make_icon_label(icon: String, color: Color) -> Label:
	var label := Label.new()
	label.text = icon
	label.add_theme_font_size_override("font_size", 18)
	label.modulate = color
	label.modulate.a = 0.0   
	label.z_index = 20
	return label

func _refresh_block_label() -> void:
	if _block_label:
		_block_label.text = "🛡" if block_charges == 1 else "🛡x%d" % block_charges

func _refresh_poison_label() -> void:
	if _poison_label:
		_poison_label.text = "☠" if poison_stacks == 1 else "☠x%d" % poison_stacks

func _animate_icon_appear(label: Label) -> void:
	if label == null:
		return
	label.scale = Vector2(0.5, 0.5)
	label.modulate.a = 0.0
	var tween := card.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.25)
	tween.tween_property(label, "modulate:a", 1.0, 0.2)

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
