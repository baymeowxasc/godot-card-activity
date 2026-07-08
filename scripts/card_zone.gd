# card_zone.gd
extends Node2D
class_name CardZone

enum ZoneType { DECK, HAND, FIELD, GRAVEYARD }

@export var zone_type: ZoneType

@onready var slots: Array = $Slots.get_children()  # all Marker2D children

var cards: Array[Control] = []       # cards currently in this zone
var slot_map: Dictionary = {}        # slot Marker2D → card (or null)

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	for slot in slots:
		slot_map[slot] = null        # all slots start empty


# ── called by GameBoard when a card is dropped over this zone ─────────────────
func try_accept_card(card: Control) -> bool:
	match zone_type:
		ZoneType.FIELD:
			if card.state != card.State.IN_HAND:
				return false
		ZoneType.HAND:
			pass
		ZoneType.DECK:
			pass
		ZoneType.GRAVEYARD:
			pass
	var slot = _nearest_open_slot(card.global_position)
	if slot == null:
		return false
	_place_card(card, slot)
	return true


# ── called by GameBoard to move a card out (e.g. draw from deck to hand) ──────
func remove_card(card: Control) -> void:
	var slot = _slot_of(card)
	if slot:
		slot_map[slot] = null
	cards.erase(card)


# ── draw the top card (used by Deck zone) ─────────────────────────────────────
func pop_top_card() -> Control:
	if cards.is_empty():
		return null
	var card: Control = cards.back()
	remove_card(card)
	return card


# ── place a card into a specific slot (used internally and by hand fan logic) ─
func _place_card(card: Control, slot: Marker2D) -> void:
	# if card was already in another zone, clean that up first
	if card.current_zone != null and card.current_zone != self:
		card.current_zone.remove_card(card)

	card.current_zone = self
	slot_map[slot] = card
	cards.append(card)

	match zone_type:
		ZoneType.DECK:
			_place_in_deck(card, slot)
		ZoneType.HAND:
			_place_in_hand(card, slot)
		ZoneType.FIELD:
			_place_on_field(card, slot)
		ZoneType.GRAVEYARD:
			_place_in_graveyard(card, slot)


# ── DECK: face-down, stacked ──────────────────────────────────────────────────
func _place_in_deck(card: Control, slot: Marker2D) -> void:
	card.set_state(card.State.IN_DECK)
	card.face_down()
	var t := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	t.tween_property(card, "global_position", slot.global_position, 0.2)


# ── HAND: face-up, fanned out ─────────────────────────────────────────────────
func _place_in_hand(card: Control, slot: Marker2D) -> void:
	card.set_state(card.State.IN_HAND)
	card.face_up()
	_refresh_hand_fan()


func _refresh_hand_fan() -> void:
	# evenly space cards across the hand slots
	var hand_cards := cards
	var count := hand_cards.size()
	for i in count:
		var slot: Marker2D = slots[i] if i < slots.size() else slots.back()
		var t := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		t.tween_property(hand_cards[i], "global_position", slot.global_position, 0.25)


# ── FIELD: face-up, locked into slot ─────────────────────────────────────────
func _place_on_field(card: Control, slot: Marker2D) -> void:
	card.set_state(card.State.ON_FIELD)
	var t := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(card, "global_position", slot.global_position, 0.2)


# ── GRAVEYARD: face-up, stacked, play death animation ────────────────────────
func _place_in_graveyard(card: Control, slot: Marker2D) -> void:
	card.set_state(card.State.DEAD)
	# slightly offset each card so the stack looks physical
	var offset := Vector2(cards.size() * 1.5, cards.size() * -1.5)
	var target := slot.global_position + offset
	var t := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	t.tween_property(card, "global_position", target, 0.3)


# ── helpers ───────────────────────────────────────────────────────────────────
func _nearest_open_slot(world_pos: Vector2) -> Marker2D:
	var best: Marker2D = null
	var best_dist := INF
	for slot in slots:
		if slot_map[slot] != null:
			continue                 # occupied
		var d := world_pos.distance_to(slot.global_position)
		if d < best_dist:
			best_dist = d
			best = slot
	return best


func _slot_of(card: Control) -> Marker2D:
	for slot in slot_map:
		if slot_map[slot] == card:
			return slot
	return null


func is_full() -> bool:
	return cards.size() >= slots.size()


func is_empty() -> bool:
	return cards.is_empty()
	
func contains_point(point: Vector2) -> bool:
	var shape: Shape2D = $Area2D/CollisionShape2D.shape
	if shape is RectangleShape2D:
		var rect := Rect2(
			global_position - shape.size / 2,
			shape.size
		)
		return rect.has_point(point)
	return false
