extends Node2D

@export var card_data_list: Array[CardData] = []

var draw_pile: Array[CardData] = []
var mouse_in: bool = false

func _ready() -> void:
	add_to_group("deck")
	print("card_data_list size: ", card_data_list.size())
	draw_pile = card_data_list.duplicate()
	draw_pile.shuffle()
	print("draw_pile size: ", draw_pile.size())

func _on_area_2d_mouse_entered() -> void:
	mouse_in = true

func _on_area_2d_mouse_exited() -> void:
	mouse_in = false

func _process(_delta: float) -> void:
	if mouse_in and Input.is_action_just_pressed("click"):
		draw_card()

func draw_card() -> void:
	if draw_pile.is_empty():
		return
	var data = draw_pile.pop_back()
	CardManager.draw_card(data, global_position)
	print("card drawn")

func is_empty() -> bool:
	return draw_pile.is_empty()
