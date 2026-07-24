extends Node2D

var buried: Array[Node2D] = []

func _ready() -> void:
	CardManager.graveyard = self

func receive(card: Node2D) -> void:
	buried.append(card)
	card.set_physics_process(false)
	card.set_process(false)
	card.set_health_label_visible(false)
	var offset = Vector2(buried.size() * 2, buried.size() * -2)
	card.global_position = global_position + offset
	card.visible = true
	card.visuals.reappear()
