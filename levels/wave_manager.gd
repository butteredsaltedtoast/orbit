class_name WaveManager
extends Node

@export var enemy_scene: PackedScene
@export var ddos_scene: PackedScene
@export var wave_dur: float = 25
@export var break_dur: float = 3
@export var spawn_radius: float = 400
@export var base_interval: float = 1.5
@export var ramp: float = 0.88
@export var min_interval: float = 0.3
@export var enemies: Node2D
@export var clump_size: int = 6
@export var ddos_chance: float = 0.25

var in_wave: bool = false
var wave_time_left: float
var spawn_cooldown: float
var break_time_left: float
var in_run: bool = true

func _ready() -> void:
	start_wave()
	GameState.run_ended.connect(func(): in_run = false)

func _physics_process(delta: float) -> void:
	if not in_run:
		return
	if in_wave:
		wave_time_left -= delta
		spawn_cooldown -= delta
		if spawn_cooldown <= 0:
			spawn_enemy()
			spawn_cooldown = max(min_interval, base_interval * pow(ramp, GameState.wave))
		if wave_time_left <= 0:
			end_wave()
	else:
		break_time_left -= delta
		if break_time_left <= 0:
			start_wave()
	
func start_wave() -> void:
	GameState.wave += 1
	GameState.wave_changed.emit(GameState.wave)
	in_wave = true
	wave_time_left = wave_dur
	spawn_cooldown = 0
	
func end_wave() -> void:
	in_wave = false
	break_time_left = break_dur
	
func spawn_enemy() -> void:
	if not is_instance_valid(GameState.player):
		return
	if GameState.wave >= 3:
		if randf() < ddos_chance:
			var spawn_dir: Vector2 = Vector2.from_angle(randf_range(0, TAU))
			for i in range(clump_size):
				var d: Enemy = ddos_scene.instantiate()
				d.position = GameState.player.global_position + spawn_radius * spawn_dir + Vector2(randf_range(-12, 12), randf_range(-12, 12))
				enemies.add_child(d)
			return
	var enemy: Enemy = enemy_scene.instantiate()
	enemy.position = GameState.player.global_position + spawn_radius * Vector2.from_angle(randf_range(0, TAU))
	enemies.add_child(enemy)
