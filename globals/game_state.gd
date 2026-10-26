extends Node

signal hp_changed(curr: float, mx: float)
signal wave_changed(wv: int)
signal run_ended

var player: Player = null
var wave: int = 0

func hitstop(duration: float) -> void:
	Engine.time_scale = 0.01
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1
	
func add_shake(amt: float) -> void:
	if is_instance_valid(player):
		player.cam.add_trauma(amt)

func reset() -> void:
	wave = 0
	player = null
	Engine.time_scale = 1.0
