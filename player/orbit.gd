extends Node2D

@export var max_slots: int = 3
@export var orbit_radius: float = 50.0
@export var spin_speed: float = 4.0
@export var follow_speed: float = 15.0
@export var hook_scene: PackedScene

@onready var zone: Area2D = $DebugGrabZone

var captured: Array[Enemy] = []
var base_angle: float = 0.0
var hook_out: bool = false

func _physics_process(delta: float) -> void:
	var aim_dir: Vector2 = global_position.direction_to(get_global_mouse_position())
	#if Input.is_action_just_pressed("debug_grab") and captured.size() < max_slots:
		#var nearest: Enemy = null
		#for x in zone.get_overlapping_bodies():
			#if x is Enemy:
				#if nearest == null or x.global_position.distance_squared_to(global_position) < nearest.global_position.distance_squared_to(global_position):
					#nearest = x
		#if nearest != null:
			#captured.append(nearest)
			#nearest.capture()
	if Input.is_action_just_pressed("hook"):
		if not (hook_out or captured.size() >= max_slots):
			var hook: Hook = hook_scene.instantiate()
			add_child(hook)
			hook.latched.connect(on_hook_latched)
			hook.returned.connect(on_hook_returned)
			hook.launch(global_position, aim_dir)
			hook_out = true
	captured = captured.filter(func(x): return is_instance_valid(x))
	if Input.is_action_just_pressed("fling") and captured.size() != 0:
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
	base_angle = wrapf(base_angle + spin_speed * delta, 0, TAU)
	var w: float = 1.0 - exp(-follow_speed * delta)
	for i in range(captured.size()):
		var target: Vector2 = global_position + Vector2.from_angle(base_angle + i * TAU / captured.size()) * orbit_radius
		captured[i].global_position = captured[i].global_position.lerp(target, w)

func on_hook_latched(enemy: Enemy) -> void:
	hook_out = false
	if captured.size() >= max_slots:
		return
	captured.append(enemy)
	enemy.capture()

func on_hook_returned() -> void:
	hook_out = false
