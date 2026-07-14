extends Button

enum Action { DAMAGE, POISON, TICK_POISON }

@export var target_slot: NodePath
@export var action: Action = Action.DAMAGE

func _on_pressed() -> void:
	var slot = get_node(target_slot)
	if not slot or not slot.is_occupied:
		return
	var card = slot.occupant
	match action:
		Action.DAMAGE:
			card.take_damage(randi_range(1, 3))
		Action.POISON:
			card.apply_poison(1)
		Action.TICK_POISON:
			card.tick_poison()
