extends Node2D

func play() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var center = viewport_size / 2.0
	global_position = center

	var flash = $ScreenFlash
	flash.size = viewport_size
	flash.position = -center

	# Reset halves to starting state
	$TopHalf.scale = Vector2(0, 0)
	$TopHalf.position = Vector2(3, -41)
	$TopHalf.modulate.a = 0.0
	$BottomHalf.scale = Vector2(0, 0)
	$BottomHalf.position = Vector2(-17, 20)
	$BottomHalf.modulate.a = 0.0

	visible = true
	$AnimationPlayer.play("break")
	$AnimationPlayer.animation_finished.connect(_on_done, CONNECT_ONE_SHOT)

func _on_done(_anim_name: String) -> void:
	queue_free()
