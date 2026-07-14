# card_slot.gd
extends Node2D

var card_hovering: Node2D = null
var is_occupied: bool = false
var occupant: Node2D = null

func _ready() -> void:
	add_to_group("card_slots")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_occupied:
		return
	var card = area.get_parent()
	if card.is_in_group("cards"):
		card_hovering = card

func _on_area_2d_area_exited(area: Area2D) -> void:
	if is_occupied:
		return
	if area.get_parent() == card_hovering:
		card_hovering = null

func _process(_delta: float) -> void:
	if card_hovering and not is_occupied and Input.is_action_just_released("click"):
		var hand = get_tree().get_first_node_in_group("hand")
		hand.remove_card(card_hovering)
		card_hovering.snap_to(global_position)
		card_hovering.current_slot = self    
		is_occupied = true
		occupant = card_hovering
		card_hovering = null  
		$Area2D.monitoring = false
		
func on_card_removed() -> void:
	is_occupied = false
	occupant = null
	card_hovering = null
	$Area2D.monitoring = true
