extends Control

const GAME_SCENE := "res://Scenes/Game.tscn"
const SETTINGS_SCENE := "res://SettingsUI.tscn"

@onready var options := $MainMenu/MarginContainer/VBoxContainer/MenuOptions
@onready var new_game_btn: Button = options.get_node("NewGame")
@onready var continue_btn: Button = options.get_node("Continue")
@onready var settings_btn: Button = options.get_node("Settings")
@onready var exit_btn: Button = options.get_node("Exit")

func _ready() -> void:
	continue_btn.disabled = not SaveManager.has_save()
	new_game_btn.pressed.connect(_on_new_game)
	continue_btn.pressed.connect(_on_continue)
	settings_btn.pressed.connect(_on_settings)
	exit_btn.pressed.connect(get_tree().quit)

func _on_new_game() -> void:
	SaveManager.load_on_start = false
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_continue() -> void:
	SaveManager.load_on_start = true
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_settings() -> void:
	if ResourceLoader.exists(SETTINGS_SCENE):
		get_tree().change_scene_to_file(SETTINGS_SCENE)
	else:
		print("Settings: jeszcze nie zrobione")
