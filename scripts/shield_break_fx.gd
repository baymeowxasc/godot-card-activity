extends Node2D

func play() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var center = viewport_size / 2.0
	global_position = center
	$ScreenFlash.size = viewport_size
	$ScreenFlash.position = -center
	visible = true
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("break")
	$AnimationPlayer.animation_finished.connect(_on_done, CONNECT_ONE_SHOT)

func _on_done(_anim_name: String) -> void:
	queue_free()
