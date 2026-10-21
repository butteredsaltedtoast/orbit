extends CharacterBody2D

@export var max_speed: float = 250.0
@export var acceleration: float = 2500.0
@export var friction: float = 3500.0

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity: Vector2 = direction * max_speed
	if direction == Vector2.ZERO:
		velocity = velocity.move_toward(target_velocity, friction * delta)
	else:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	move_and_slide()
