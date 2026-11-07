extends Node

func _ready() -> void:
	SaveManager.save_requested.connect(_on_save_requested)

func _on_save_requested() -> void:
	SaveManager.save_game({"test": 1})
