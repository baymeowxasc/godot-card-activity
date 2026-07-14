extends Node2D

var current_slot: Node2D = null
var card_data: CardData = null

var drag: CardDrag
var visuals: CardVisuals

var status: StatusEffect

func _ready() -> void:
	add_to_group("cards")
	$Sprite2D.material = $Sprite2D.material.duplicate()
	drag = CardDrag.new()
	drag.init(self)
	add_child(drag)
	visuals = CardVisuals.new()
	visuals.init(self)
	add_child(visuals)
	status = StatusEffect.new()
	status.setup(self)
	add_child(status)
	get_tree().get_first_node_in_group("hand").add_card(self)

func _physics_process(delta: float) -> void:
	drag.process(delta)

func set_hand_position(pos: Vector2, index: int) -> void:
	drag.set_hand_position(pos, index)

func snap_to(pos: Vector2) -> void:
	drag.snap_to(pos)

func setup(data: CardData) -> void:
	card_data = data
	if data.back_texture:
		$Sprite2D.texture = data.back_texture
	$Sprite2D.scale = Vector2(0.2, 0.2)
	$HealthLabel.text = str(card_data.current_health)
	$HealthLabel.z_index = 10
	var starting_block = card_data.roll_starting_block()
	if starting_block > 0:
		status.add_block(starting_block)

func play_draw_animation(deck_pos: Vector2, hand_pos: Vector2) -> void:
	visuals.play_draw_animation(deck_pos, hand_pos)

func reappear() -> void:
	visuals.reappear()

func take_damage(amount: int) -> void:
	if card_data == null:
		return
	if status.has_block():
		status.consume_block()
		return
	card_data.current_health -= amount
	$HealthLabel.text = str(card_data.current_health)
	if card_data.current_health > 0:
		visuals.play_hit_animation(amount)
	else:
		visuals.dissolve(die)

func apply_poison(stacks: int = 1) -> void:
	status.add_poison(stacks)

func tick_poison() -> void:
	if status.poison_stacks <= 0:
		return
	var dmg = status.poison_stacks
	status.tick_poison()
	if card_data and card_data.current_health > 0:
		card_data.current_health -= dmg
		$HealthLabel.text = str(card_data.current_health)
		if card_data.current_health <= 0:
			visuals.dissolve(die)

func die() -> void:
	get_tree().get_first_node_in_group("hand").cards.erase(self)
	if current_slot != null:
		current_slot.on_card_removed()
		current_slot = null
	CardManager.graveyard.receive(self)

func _on_area_2d_mouse_entered() -> void:
	drag.mouse_in = true

func _on_area_2d_mouse_exited() -> void:
	drag.mouse_in = false
	if not drag.is_dragging:
		$Sprite2D.z_index = 0
		drag.change_scale(Vector2(0.2, 0.2))

func set_health_label_visible(value: bool) -> void:
	$HealthLabel.visible = value
