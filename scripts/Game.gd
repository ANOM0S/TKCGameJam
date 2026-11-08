extends Node

# Zarządzanie zapisem
func _ready() -> void:
	SaveManager.save_requested.connect(_on_save_requested)
	if SaveManager.load_on_start:
		%GameManager.apply_save_data(SaveManager.load_game())
	else:
		%GameManager.reset()

func _on_save_requested() -> void:
	SaveManager.save_game(%GameManager.get_save_data())
