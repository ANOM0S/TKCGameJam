extends Control

# Referencje do scen
const GAME_SCENE := "res://Scenes/Game.tscn"
const SETTINGS_SCENE := "res://Scenes/SettingsUI.tscn"

# Połączenie z przyciskami
@onready var options := $MainMenu/MarginContainer/VBoxContainer/MenuOptions
@onready var new_game_btn: Button = options.get_node("NewGame")
@onready var settings_btn: Button = options.get_node("Settings")
@onready var exit_btn: Button = options.get_node("Exit")

func _ready() -> void:
	new_game_btn.pressed.connect(_on_new_game)
	settings_btn.pressed.connect(_on_settings)
	exit_btn.pressed.connect(get_tree().quit)

# Zaczynamy nową grę
func _on_new_game() -> void:
	SaveManager.load_on_start = false
	get_tree().change_scene_to_file(GAME_SCENE)

# Ustawienia których jeszcze nie mamy :p
func _on_settings() -> void:
	get_tree().change_scene_to_file(SETTINGS_SCENE)
