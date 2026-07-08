extends Node2D

@export var spread: float = 160.0

var cards: Array[Node2D] = []

func _ready() -> void:
	var screen_size = get_viewport_rect().size
	global_position = Vector2(screen_size.x * 0.5, screen_size.y - 150)

func add_card(card: Node2D) -> void:
	cards.append(card)
	arrange()

func remove_card(card: Node2D) -> void:
	cards.erase(card)
	arrange()

func arrange() -> void:
	var count = cards.size()
	for i in count:
		var t = 0.5 if count == 1 else float(i) / (count - 1)
		var x = lerp(-spread * (count - 1) * 0.5, spread * (count - 1) * 0.5, t)
		cards[i].set_hand_position(global_position + Vector2(x, 0), i)
