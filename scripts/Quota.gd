extends Node

@onready var submit_a_quota: Button = $MarginContainer/SubmitAQuota
@onready var game_manager = %GameManager

func _on_submit_a_quota_pressed() -> void:
	game_manager._pay_a_quota()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
