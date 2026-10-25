class_name Player
extends CharacterBody2D

@export var max_speed: float = 125.0
@export var acceleration: float = 1250.0
@export var friction: float = 1750.0
@export var max_hp: float = 100.0

@onready var inv_timer: Timer = $InvincibleTimer
@onready var hurtbox: Area2D = $Hurtbox
@onready var sprite: Sprite2D = $Sprite2D
@onready var cam: CustomCam = $Camera2D

var current_hp: float
var tween: Tween
var dead: bool = false

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
	if(!inv_timer.is_stopped()) or dead:
		return
	current_hp = max(current_hp - damage, 0)
	GameState.hp_changed.emit(current_hp, max_hp)
	if(current_hp <= 0):
		print("dead")
		dead = true
		return
	else:
		print("hp: ", current_hp)
		inv_timer.start()
		if tween and tween.is_valid():
			tween.kill()
			sprite.modulate = Color.WHITE
		tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(10, 10, 10), 0)
		tween.tween_interval(inv_timer.wait_time / 3)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0)
		tween.tween_interval(inv_timer.wait_time / 3)
		tween.tween_property(sprite, "modulate", Color(10, 10, 10), 0)
		tween.tween_interval(inv_timer.wait_time / 3)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Enemy:
		take_damage(10.0)

func _on_invincible_timer_timeout() -> void:
	if hurtbox.get_overlapping_bodies().any(func(x): return x is Enemy):
		take_damage(10.0)
