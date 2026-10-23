extends Node

var player: Player = null
var wave: int = 0

func hitstop(duration: float) -> void:
	Engine.time_scale = 0
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1
	
func add_shake(amt: float) -> void:
	if is_instance_valid(player):
		player.cam.add_trauma(amt)
