extends Button

@export var target_slot: NodePath

func _on_pressed() -> void:
	var slot = get_node(target_slot)
	print("slot: ", slot)
	print("is_occupied: ", slot.is_occupied if slot else "NULL SLOT")
	if slot and slot.is_occupied:
		print("dealing damage to: ", slot.occupant)
		slot.occupant.take_damage(1)

func destroy_card(slot: Node2D) -> void:
	var card = slot.occupant
	var graveyard = get_tree().get_first_node_in_group("graveyard")
	
	# free the slot
	slot.on_card_removed()
	
	# remove from hand tracking just in case
	var hand = get_tree().get_first_node_in_group("hand")
	hand.cards.erase(card)
	
	# send to graveyard
	graveyard.receive(card)
