extends CanvasLayer

@onready var hpbar: ProgressBar = $MarginContainer/Control/HPbar
@onready var wvlabel: Label = $MarginContainer/Control/Wavelabel
@onready var cdlabel: Label = $MarginContainer/Control/Countdownlabel

@export var wave_manager: WaveManager

func _ready() -> void:
	GameState.hp_changed.connect(update_hp)
	GameState.wave_changed.connect(update_wave)
	update_wave(GameState.wave)
	if is_instance_valid(GameState.player):
		update_hp(GameState.player.current_hp, GameState.player.max_hp)
	
func _process(_delta: float) -> void:
	if wave_manager == null:
		return
	cdlabel.text = "to end of wave: " + str(ceili(wave_manager.wave_time_left)) if wave_manager.in_wave else "break for: " + str(ceili(wave_manager.break_time_left))
	
func update_hp(curr: float, mx: float) -> void:
	hpbar.max_value = mx
	hpbar.value = curr

func update_wave(wave: int) -> void:
	wvlabel.text = "wave: " + str(wave)
