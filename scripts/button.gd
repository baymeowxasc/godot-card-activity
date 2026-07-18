extends Button

enum Action { DAMAGE, POISON }

@export var target_slot: NodePath
@export var action: Action = Action.DAMAGE

func _on_pressed() -> void:
	var slot = get_node(target_slot)
	if not slot or not slot.is_occupied:
		return
	var occupant = slot.occupant
	if occupant.card_data == null or occupant.card_data.current_health <= 0:
		return
	match action:
		Action.DAMAGE:
			occupant.take_damage(randi_range(1, 3))
		Action.POISON:
			occupant.apply_poison(1)
