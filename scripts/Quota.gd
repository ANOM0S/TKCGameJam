extends Node

@onready var submit_a_quota: Button = $MarginContainer/SubmitAQuota
@onready var game_manager = %GameManager
@onready var quota: Label = $Dym/Quota

func _on_submit_a_quota_pressed() -> void:
	game_manager._pay_a_quota()

func _process(_delta: float) -> void:
	quota.text = "Do następnego razu potrzebujesz " + str(game_manager.quota) + " robaków."
