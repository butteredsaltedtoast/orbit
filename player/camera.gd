class_name CustomCam
extends Camera2D

@export var max_offset: float = 3.0
@export var decay: float = 1.5

var trauma: float = 0.0

func _process(delta: float) -> void:
	trauma = move_toward(trauma, 0, decay * delta)
	var strength: float = max_offset * trauma * trauma
	offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))

func add_trauma(amt: float) -> void:
	trauma = min(trauma + amt, 1.0)
