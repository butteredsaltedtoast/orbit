class_name Player
extends CharacterBody2D

@export var max_speed: float = 250.0
@export var acceleration: float = 2500.0
@export var friction: float = 3500.0
@export var max_hp: float = 100.0
@onready var inv_timer: Timer = $InvincibleTimer
@onready var hurtbox: Area2D = $Hurtbox
var current_hp: float

func _ready() -> void:
	GameState.player = self
	current_hp = max_hp

func _exit_tree() -> void:
	if(GameState.player == self):
		GameState.player = null

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity: Vector2 = direction * max_speed
	if direction == Vector2.ZERO:
		velocity = velocity.move_toward(target_velocity, friction * delta)
	else:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	move_and_slide()
	
func take_damage(damage: float) -> void:
	if(!inv_timer.is_stopped()):
		return
	current_hp -= damage
	if(current_hp <= 0):
		current_hp = 0	
		print("dead")
	else:
		print("hp: ", current_hp)
		inv_timer.start()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Enemy:
		take_damage(10.0)

func _on_invincible_timer_timeout() -> void:
	if hurtbox.get_overlapping_bodies().any(func(x): return x is Enemy):
		take_damage(10.0)
