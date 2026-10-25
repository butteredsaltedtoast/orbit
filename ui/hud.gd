extends CanvasLayer

@onready var hpbar: ProgressBar = $MarginContainer/Control/HPbar
@onready var wvlabel: Label = $MarginContainer/Control/Wavelabel
@onready var cdlabel: Label = $MarginContainer/Control/Countdownlabel

func _ready() -> void:
	GameState.hp_changed.connect(update_hp)
	GameState.wave_changed.connect(update_wave)
	
func update_hp(hp: float) -> void:
	hpbar.progress = hp

func update_wave(wave:float) -> void:
	pass
