extends Node

# Ścieżki do scen
const MENU_SCENE := "res://scenes/MenuUI.tscn"
const SETTINGS_SCENE := "res://Scenes/SettingsUI.tscn"

# Powiązania z przyciskami
@onready var panel: Control = $MainMenu
@onready var resume_btn: TextureButton = $MainMenu/VBoxContainer/VBoxContainer/Resume
@onready var quit_btn: TextureButton = $MainMenu/VBoxContainer/VBoxContainer/Quit

func _ready() -> void:
	add_to_group("pause_menu")
	panel.visible = false
	resume_btn.pressed.connect(close)
	quit_btn.pressed.connect(_on_quit)

func open() -> void:
	panel.visible = true
	get_tree().paused = true

func close() -> void:
	panel.visible = false
	get_tree().paused = false

func _on_quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if panel.visible:
			close()
		else:
			open()
