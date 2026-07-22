extends Resource
class_name CardData

@export var card_name: String = ""
@export var front_texture: Texture2D = null
@export var back_texture: Texture2D = null
@export var max_health: int = 5
@export var attack: int = 1
@export var block_charges: int = 0                  
@export_range(0.0, 1.0) var block_chance: float = 0.0 

var current_health: int

func _init() -> void:
	current_health = max_health

func roll_starting_block() -> int:
	var charges = block_charges
	if block_chance > 0.0 and randf() < block_chance:
		charges += 1
	return charges
