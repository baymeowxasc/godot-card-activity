extends Button

@export var target_slot: NodePath

func _on_pressed() -> void:
	var slot = get_node(target_slot)
	print("slot: ", slot)
	print("is_occupied: ", slot.is_occupied if slot else "NULL SLOT")
	if slot and slot.is_occupied:
		print("dealing damage to: ", slot.occupant)
		slot.occupant.take_damage(1)
