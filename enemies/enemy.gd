class_name Enemy
extends CharacterBody2D

@export var speed: float = 80.0
@export var fling_speed: float = 550.0
@export var fling_friction: float = 850.0

enum State {CHASING, ORBITING, FLUNG}
var state: State = State.CHASING

func _physics_process(delta: float) -> void:
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
			for i in range(get_slide_collision_count()):
				var coll: Object = get_slide_collision(i).get_collider()
				if coll is Enemy:
					coll.queue_free()
					queue_free()
					return
			velocity = velocity.move_toward(Vector2.ZERO, fling_friction * delta)
			if velocity.length() < speed:
				state = State.CHASING
				set_collision_layer_value(3, false)
				set_collision_layer_value(2, true)
				set_collision_mask_value(2, true)
	move_and_slide()
	
func capture() -> void:
	state = State.ORBITING
	set_collision_layer_value(2, false)
	set_collision_mask_value(2, false)
	velocity = Vector2.ZERO

func fling(direction: Vector2) -> void:
	state = State.FLUNG
	velocity = direction * fling_speed
	set_collision_layer_value(3, true)
	set_collision_mask_value(2, true)
