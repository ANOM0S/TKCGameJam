extends Node

const MENU_SCENE := "res://scenes/MenuUI.tscn"
const SETTINGS_SCENE := "res://SettingsUI.tscn"

@onready var panel: Control = $MainMenu
@onready var resume_btn: Button = $MainMenu/VBoxContainer/VBoxContainer/Resume
@onready var save_btn: Button = $MainMenu/VBoxContainer/VBoxContainer/Save
@onready var quit_btn: Button = $MainMenu/VBoxContainer/VBoxContainer/Quit
@onready var settings_btn: Button = $MainMenu/VBoxContainer/VBoxContainer/Settings

func _ready() -> void:
	add_to_group("pause_menu")
	panel.visible = false
	resume_btn.pressed.connect(close)
	save_btn.pressed.connect(_on_save)
	quit_btn.pressed.connect(_on_quit)

func open() -> void:
	panel.visible = true
	get_tree().paused = true

func close() -> void:
	panel.visible = false
	get_tree().paused = false

func _on_save() -> void:
	SaveManager.save_requested.emit()
	save_btn.text = "Zapisano!"
	await get_tree().create_timer(1.0).timeout
	save_btn.text = "Zapisz"

func _on_quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if panel.visible:
			close()
		else:
			open()

func _on_settings() -> void:
	if ResourceLoader.exists(SETTINGS_SCENE):
		get_tree().change_scene_to_file(SETTINGS_SCENE)
	else:
		print("Settings: jeszcze nie zrobione")
