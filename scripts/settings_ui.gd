extends Control

const MENU_SCENE := "res://scenes/MenuUI.tscn"

@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SfxSlider
@onready var fullscreen_check: CheckBox = %FullscreenCheck
@onready var back_button: Button = %BackButton

func _ready() -> void:
	master_slider.value = Settings.master
	music_slider.value = Settings.music
	sfx_slider.value = Settings.sfx
	fullscreen_check.button_pressed = Settings.fullscreen

	master_slider.value_changed.connect(func(v): Settings.master = v; Settings.apply())
	music_slider.value_changed.connect(func(v): Settings.music = v; Settings.apply())
	sfx_slider.value_changed.connect(func(v): Settings.sfx = v; Settings.apply())
	fullscreen_check.toggled.connect(func(on): Settings.fullscreen = on; Settings.apply())
	back_button.pressed.connect(_on_back)

func _on_back() -> void:
	Settings.save_settings()
	get_tree().change_scene_to_file(MENU_SCENE)
