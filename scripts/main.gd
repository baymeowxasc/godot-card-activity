extends Node2D

@export var card_scene: PackedScene

func _ready() -> void:
	CardManager.card_scene = card_scene
	print("card_scene set to: ", card_scene)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("spacebar"):  
		CardManager.draw_card()
