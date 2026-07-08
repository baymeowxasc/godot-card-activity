extends Node

@export var card_scene: PackedScene
@export var starting_deck: Array[CardData]

@onready var cards_node = $"../Cards"

@onready var deck: CardZone = $"../Zones/Deck"
@onready var hand: CardZone = $"../Zones/Hand"
@onready var field: CardZone = $"../Zones/Field"
@onready var graveyard: CardZone = $"../Zones/Graveyard"

var zones: Array[CardZone]

func _ready():

	zones = [
		deck,
		hand,
		field,
		graveyard
	]
	
	_create_deck()
	draw_cards(5)
	

func _create_deck():
	for data in starting_deck:
		var card = card_scene.instantiate()
		cards_node.add_child(card)
		$"../Cards".add_child(card)
		card.card_data = data
		card.card_dropped.connect(_on_card_dropped)
		deck.try_accept_card(card)
	shuffle()

func shuffle():
	deck.cards.shuffle()
	for i in deck.cards.size():
		var card = deck.cards[i]
		card.global_position = deck.slots[0].global_position + Vector2(0, -i)
		

func draw_cards(amount: int):
	for i in amount:
		var card = deck.pop_top_card()
		if card == null:
			return
		hand.try_accept_card(card)

func _on_card_dropped(card: Control, world_pos: Vector2):
	var zone := _find_zone(world_pos)
	if zone == null:
		hand.try_accept_card(card)
		return
	if zone == hand:
		hand.try_accept_card(card)
		return
	if zone == field:
		if field.try_accept_card(card):
			return
	hand.try_accept_card(card)

func _find_zone(point: Vector2) -> CardZone:
	for zone in zones:
		if zone.contains_point(point):
			return zone
	return null
	
func send_to_grave(card):
	graveyard.try_accept_card(card)
	
func draw_card():
	draw_cards(1)

func begin_turn():
	draw_card()
	
