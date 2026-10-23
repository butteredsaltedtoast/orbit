class_name Hook
extends Area2D

enum State {FLYING, RETRACTING}

signal latched(enemy: Enemy)
signal returned

@export var speed: float = 500.0
@export var return_speed: float = 700.0
@export var max_range: float = 120.0

var state: State
var direction: Vector2
var distance_travelled: float

func _physics_process(delta: float) -> void:
	if state == State.FLYING:
		global_position += direction * speed * delta
		distance_travelled += speed * delta
		if distance_travelled >= max_range:
			state = State.RETRACTING
	if state == State.RETRACTING:
		if not is_instance_valid(GameState.player):
			queue_free()
			return
		global_position = global_position.move_toward(GameState.player.global_position, return_speed * delta)
		if global_position.distance_squared_to(GameState.player.global_position) <= 8 * 8:
			returned.emit()
			queue_free()
	
func launch(from_position: Vector2, aim_direction: Vector2) -> void:
	global_position = from_position
	direction = aim_direction
	distance_travelled = 0.0
	state = State.FLYING

func _on_body_entered(body: Node2D) -> void:
	if state == State.FLYING and body is Enemy:
		latched.emit(body)
		queue_free()
