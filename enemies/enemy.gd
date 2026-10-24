class_name Enemy
extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D

@export var speed: float = 80.0
@export var fling_speed: float = 550.0
@export var fling_friction: float = 850.0
@export var fling_kb: float = 250.0
@export var max_hp: float = 3.0
@export var fling_damage: float = 3.0
@export var kb_decay: float = 600.0

enum State {CHASING, ORBITING, FLUNG}
var state: State = State.CHASING
var hp: float
var kb: Vector2 = Vector2.ZERO
var hurt_timer: float = 0.0
var tween: Tween

func _ready() -> void:
	hp = max_hp

func _physics_process(delta: float) -> void:
	hurt_timer = move_toward(hurt_timer, 0, delta)
	kb = kb.move_toward(Vector2.ZERO, kb_decay * delta)
	match state:
		State.CHASING:
			var direction: Vector2 = Vector2.ZERO
			if is_instance_valid(GameState.player):
				direction = global_position.direction_to(GameState.player.global_position)
			velocity = direction * speed + kb
		State.ORBITING:
			#print("spin-ning, spin-ning♪♫")
			pass
		State.FLUNG:
			for i in range(get_slide_collision_count()):
				var coll: Object = get_slide_collision(i).get_collider()
				if coll is Enemy:
					coll.take_damage(fling_damage, velocity.normalized() * fling_kb)
					GameState.hitstop(0.05)
					GameState.add_shake(0.4)
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
	
func take_damage(amt: float, push: Vector2) -> void:
	if hurt_timer > 0:
		return
	hp -= amt
	kb = push
	hurt_timer = 0.15
	tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(10, 10, 10), 0)
	tween.tween_interval(hurt_timer / 3)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0)
	tween.tween_interval(hurt_timer / 3)
	tween.tween_property(sprite, "modulate", Color(10, 10, 10), 0)
	tween.tween_interval(hurt_timer / 3)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0)
	if hp <= 0:
		queue_free()
