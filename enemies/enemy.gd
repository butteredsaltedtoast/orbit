class_name Enemy
extends CharacterBody2D

@onready var visual: Node2D = $Visual
@onready var sprite: Sprite2D = $Visual/Sprite2D
@onready var qsprite: Sprite2D = $Visual/QuarantineSprite
@onready var orbit_hitbox: Area2D = $OrbitHitbox

@export var speed: float = 80.0
@export var fling_speed: float = 550.0
@export var fling_friction: float = 850.0
@export var fling_kb: float = 250.0
@export var max_hp: float = 3.0
@export var fling_damage: float = 3.0
@export var kb_decay: float = 600.0
@export var orbit_damage: float = 1.0
@export var orbit_kb: float = 200.0
@export var orbit_hits: int = 3
@export var burst: PackedScene

enum State {CHASING, ORBITING, FLUNG, LEAVING}
var state: State = State.CHASING
var hp: float
var hits_left: int
var kb: Vector2 = Vector2.ZERO
var hurt_timer: float = 0.0
var tween: Tween
var qtween: Tween
var ltween: Tween
var dead: bool = false

func _ready() -> void:
	hp = max_hp
	hits_left = orbit_hits
	GameState.run_ended.connect(leave)

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
			qsprite.modulate.a = clampf((velocity.length() - speed) / (fling_speed - speed), 0, 1.0)
			for i in range(get_slide_collision_count()):
				var coll: Object = get_slide_collision(i).get_collider()
				if coll is Enemy:
					coll.take_damage(fling_damage, velocity.normalized() * fling_kb)
					GameState.hitstop(0.05)
					GameState.add_shake(0.4)
					die()
					return
			velocity = velocity.move_toward(Vector2.ZERO, fling_friction * delta)
			if velocity.length() < speed:
				state = State.CHASING
				set_collision_layer_value(3, false)
				set_collision_layer_value(2, true)
				set_collision_mask_value(2, true)
				qsprite.modulate.a = 0
		State.LEAVING:
			if is_instance_valid(GameState.player):
				velocity = speed * 1.5 * GameState.player.global_position.direction_to(global_position)
	move_and_slide()
	
func capture() -> void:
	if state == State.LEAVING or dead:
		return
	state = State.ORBITING
	set_collision_layer_value(2, false)
	set_collision_mask_value(2, false)
	velocity = Vector2.ZERO
	if qtween and qtween.is_valid():
		qtween.kill()
	qtween = create_tween()
	qtween.tween_property(qsprite, "modulate:a", 1.0, 0.1)
	orbit_hitbox.set_deferred("monitoring", true)

func fling(direction: Vector2) -> void:
	if qtween and qtween.is_valid():
		qtween.kill()
	state = State.FLUNG
	velocity = direction * fling_speed
	set_collision_layer_value(3, true)
	set_collision_mask_value(2, true)
	orbit_hitbox.set_deferred("monitoring", false)
	
func take_damage(amt: float, push: Vector2) -> bool:
	if hurt_timer > 0 or dead:
		return false
	hp -= amt
	kb = push
	hurt_timer = 0.15
	if tween and tween.is_valid():
		tween.kill()
		visual.material.set_shader_parameter("flash_amount", 0.0)
	tween = create_tween()
	tween.tween_property(visual, "material:shader_parameter/flash_amount", 1.0, 0)
	tween.tween_interval(hurt_timer / 3)
	tween.tween_property(visual, "material:shader_parameter/flash_amount", 0.0, 0)
	tween.tween_interval(hurt_timer / 3)
	tween.tween_property(visual, "material:shader_parameter/flash_amount", 1.0, 0)
	tween.tween_interval(hurt_timer / 3)
	tween.tween_property(visual, "material:shader_parameter/flash_amount", 0.0, 0)
	if hp <= 0:
		die()
	return true

func _on_orbit_hitbox_body_entered(body: Node2D) -> void:
	if state != State.ORBITING or body is not Enemy or body == self or not is_instance_valid(GameState.player):
		return
	var push: Vector2 = GameState.player.global_position.direction_to(body.global_position) * orbit_kb
	var hit: bool = body.take_damage(orbit_damage, push)
	if not hit:
		return
	GameState.add_shake(0.15)
	hits_left -= 1
	if hits_left <= 0:
		die()

func die() -> void:
	if dead:
		return
	dead = true
	var b: CPUParticles2D = burst.instantiate()
	b.position = global_position
	self.get_parent().add_child(b)
	b.global_position = global_position
	b.emitting = true
	queue_free()

func leave() -> void:
	if dead:
		return
	state = State.LEAVING
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	orbit_hitbox.set_deferred("monitoring", false)
	if ltween and ltween.is_valid():
		ltween.kill()
	ltween = create_tween()
	ltween.tween_property(visual, "modulate:a", 0.0, 1.5)
	ltween.tween_callback(queue_free)
