extends Node

var deck: Array[Node2D] = []
var discard_pile: Array[Node2D] = []
var card_scene: PackedScene = null

func get_hand() -> Node2D:
	return get_tree().get_first_node_in_group("hand")

func draw_card(data: CardData = null) -> void:
	if card_scene == null:
		push_error("CardManager: card_scene is not set")
		return
	var card = card_scene.instantiate()
	get_tree().root.add_child(card)
	if data != null:
		card.setup(data)

func discard_card(card: Node2D) -> void:
	get_hand().remove_card(card)
	discard_pile.append(card)
