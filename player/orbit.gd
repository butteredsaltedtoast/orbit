extends Node2D

@export var max_slots: int = 3
@export var orbit_radius: float = 50.0
@export var spin_speed: float = 4.0
@export var follow_speed: float = 15.0

@onready var zone: Area2D = $DebugGrabZone

var captured: Array[Enemy] = []
var base_angle: float = 0.0

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("grab") and captured.size() < max_slots:
		var nearest: Enemy = null
		for x in zone.get_overlapping_bodies():
			if x is Enemy:
				if nearest == null or x.global_position.distance_squared_to(global_position) < nearest.global_position.distance_squared_to(global_position):
					nearest = x
		if nearest != null:
			captured.append(nearest)
			nearest.capture()
	captured = captured.filter(func(x): return is_instance_valid(x))
	if Input.is_action_just_pressed("fling") and captured.size() != 0:
		var aim_dir: Vector2 = global_position.direction_to(get_global_mouse_position())
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
