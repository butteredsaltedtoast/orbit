extends CanvasLayer

@onready var hpbar: ProgressBar = $MarginContainer/Control/HPbar
@onready var wvlabel: Label = $MarginContainer/Control/Wavelabel
@onready var cdlabel: Label = $MarginContainer/Control/Countdownlabel
@onready var dhlabel: Label = $MarginContainer/Control/Deathlabel

@export var wave_manager: WaveManager

var fillstyle: StyleBoxFlat
var pulsetween: Tween
var showtween: Tween

func _ready() -> void:
	fillstyle = hpbar.get_theme_stylebox("fill").duplicate()
	hpbar.add_theme_stylebox_override("fill", fillstyle)
	GameState.hp_changed.connect(update_hp)
	GameState.wave_changed.connect(update_wave)
	GameState.run_ended.connect(show_deathlabel)
	update_wave(GameState.wave)
	if is_instance_valid(GameState.player):
		update_hp(GameState.player.current_hp, GameState.player.max_hp)
	
func _process(_delta: float) -> void:
	if wave_manager == null:
		return
	cdlabel.text = "to end of wave: " + str(ceili(wave_manager.wave_time_left)) if wave_manager.in_wave else "break for: " + str(ceili(wave_manager.break_time_left))
	if dhlabel.visible and Input.is_action_just_pressed("restart"):
		GameState.reset()
		get_tree().reload_current_scene()
	
func update_hp(curr: float, mx: float) -> void:
	hpbar.max_value = mx
	hpbar.value = curr
	if curr / mx <= 0.3:
		fillstyle.bg_color = Color("#ff3b5c")
		if not pulsetween or not pulsetween.is_valid():
			pulsetween = create_tween()
			pulsetween.set_loops()
			pulsetween.tween_property(fillstyle, "bg_color", Color("#7a1a2c"), 0.3)
			pulsetween.tween_property(fillstyle, "bg_color", Color("#ff3b5c"), 0.3)
	else:
		if pulsetween and pulsetween.is_valid():
			pulsetween.kill()
		fillstyle.bg_color = Color("#3ee6ff")

func update_wave(wave: int) -> void:
	wvlabel.text = "wave: " + str(wave)

func show_deathlabel() -> void:
	if showtween and showtween.is_valid():
		showtween.kill()
	showtween = create_tween()
	dhlabel.modulate.a = 0.0
	dhlabel.visible = true
	showtween.tween_interval(1.0)
	showtween.tween_property(dhlabel, "modulate:a", 1.0, 0.3)
