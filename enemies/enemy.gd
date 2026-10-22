class_name Enemy
extends CharacterBody2D

@export var speed: float = 80.0

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	if is_instance_valid(GameState.player):
		direction = global_position.direction_to(GameState.player.global_position)
	velocity = direction * speed
	move_and_slide()
