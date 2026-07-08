extends Node

var deck: Array[Node2D] = []
var discard_pile: Array[Node2D] = []
var card_scene: PackedScene = null

func get_hand() -> Node2D:
	return get_tree().get_first_node_in_group("hand")

func draw_card() -> void:
	if card_scene == null:
		push_error("CardManager: card_scene is not set")
		return
	var card = card_scene.instantiate()
	get_tree().root.add_child(card)
	# hand.add_card() is called automatically from card._ready()

func discard_card(card: Node2D) -> void:
	get_hand().remove_card(card)
	discard_pile.append(card)
