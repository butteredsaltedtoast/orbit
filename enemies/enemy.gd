class_name Enemy
extends CharacterBody2D

@export var speed: float = 80.0
enum State {CHASING, ORBITING, FLUNG}
var state: State = State.CHASING

func _physics_process(_delta: float) -> void:
	match state:
		State.CHASING:
			var direction: Vector2 = Vector2.ZERO
			if is_instance_valid(GameState.player):
				direction = global_position.direction_to(GameState.player.global_position)
			velocity = direction * speed
		State.ORBITING:
			#print("spin-ning, spin-ning♪♫")
			pass
		State.FLUNG:
			#print("AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH")
			pass
	move_and_slide()
	
func capture() -> void:
	state = State.ORBITING
	set_collision_layer_value(2, false)
	set_collision_mask_value(2, false)
	velocity = Vector2.ZERO
