extends Resource
class_name CardData

@export var card_name: String = ""
@export var front_texture: Texture2D = null
@export var back_texture: Texture2D = null
@export var max_health: int = 3
var current_health: int = 0

func _init() -> void:
	current_health = max_health
