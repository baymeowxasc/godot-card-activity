extends Node2D

@export var card_scene: PackedScene

func _ready() -> void:
	CardManager.card_scene = card_scene
