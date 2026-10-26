extends Node2D

@export var max_slots: int = 3
@export var orbit_radius: float = 36.0
@export var spin_speed: float = 4.0
@export var follow_speed: float = 15.0
@export var hook_scene: PackedScene
@export var hook_cooldown: float = 0.35
@export var fling_cooldown: float = 0.15

var captured: Array[Enemy] = []
var base_angle: float = 0.0
var hook_out: bool = false
var hook_timer: float = 0.0
var fling_timer: float = 0.0
var dead: bool = false

func _ready() -> void:
	GameState.run_ended.connect(func():
		captured.clear()
		set_physics_process(false)
		dead = true
	)

func _physics_process(delta: float) -> void:
	var aim_dir: Vector2 = global_position.direction_to(get_global_mouse_position())
	hook_timer = move_toward(hook_timer, 0, delta)
	fling_timer = move_toward(fling_timer, 0, delta)
	if Input.is_action_just_pressed("hook"):
		if not (hook_out or captured.size() >= max_slots or hook_timer > 0):
			var hook: Hook = hook_scene.instantiate()
			add_child(hook)
			hook.latched.connect(on_hook_latched)
			hook.returned.connect(on_hook_returned)
			hook.launch(global_position, aim_dir)
			hook_out = true
	captured = captured.filter(func(x): return is_instance_valid(x))
	if Input.is_action_just_pressed("fling"):
		if not (captured.size() == 0 or fling_timer > 0):
			var best: Enemy = null
			var best_dot: float = -2.0
			for enemy in captured:
				var enemy_dir: Vector2 = global_position.direction_to(enemy.global_position)
				var d: float = aim_dir.dot(enemy_dir)
				if d > best_dot:
					best_dot = d
					best = enemy
			captured.erase(best)
			best.fling(aim_dir)
			fling_timer = fling_cooldown
	base_angle = wrapf(base_angle + spin_speed * delta, 0, TAU)
	var w: float = 1.0 - exp(-follow_speed * delta)
	for i in range(captured.size()):
		var target: Vector2 = global_position + Vector2.from_angle(base_angle + i * TAU / captured.size()) * orbit_radius
		captured[i].global_position = captured[i].global_position.lerp(target, w)

func on_hook_latched(enemy: Enemy) -> void:
	if dead:
		return
	hook_out = false
	hook_timer = hook_cooldown
	if captured.size() >= max_slots:
		return
	captured.append(enemy)
	enemy.capture()

func on_hook_returned() -> void:
	hook_out = false
	hook_timer = hook_cooldown
