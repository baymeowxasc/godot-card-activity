extends Node

var deck: Array[Node2D] = []
var discard_pile: Array[Node2D] = []
var card_scene: PackedScene = null

var graveyard: Node2D = null

func get_hand() -> Node2D:
	return get_tree().get_first_node_in_group("hand")

func draw_card(data: Resource = null, deck_pos: Vector2 = Vector2.ZERO) -> void:
	if card_scene == null:
		push_error("CardManager: card_scene is not set")
		return
	var card = card_scene.instantiate()
	card.global_position = deck_pos
	get_tree().root.add_child(card)
	if data != null:
		var data_copy = data.duplicate()  
		data_copy.current_health = data_copy.max_health  
		card.setup(data_copy)
	await get_tree().process_frame
	card.visuals.play_draw_animation(deck_pos, card.drag.hand_position)

func discard_card(card: Node2D) -> void:
	get_hand().remove_card(card)
	discard_pile.append(card)
