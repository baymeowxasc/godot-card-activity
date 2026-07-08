extends Sprite2D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
func _physics_process(delta: float) -> void:	
	global_position = lerp(global_position, get_global_mouse_position(), 22.0*delta)
	rotation_degrees = lerp(rotation_degrees, -12.5 if Input.is_action_pressed("click") else 0.0, 16.0*delta)
	scale = lerp(scale, Vector2(0.1, 0.1) if Input.is_action_pressed("click") else Vector2(0.05, 0.05), 16.0*delta)
	$shadow.position = Vector2(-12, 12).rotated(rotation)
