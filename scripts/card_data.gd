# card_data.gd
extends Resource
class_name CardData

@export var card_name: String = ""
@export var attack: int = 0
@export var defense: int = 0
@export var art: Texture2D
@export var back: Texture2D        # the card back texture for the flip
@export var description: String = ""
