extends Control   

@onready var pause_button: Button = $OnScreenUI/PauseButton

@onready var count_labels := {
	"ant": $OnScreenUI/Bugs/Ant/AntAmount,
	"beetle": $OnScreenUI/Bugs/Beetle/BeetleAmount,
	"caterpillar": $OnScreenUI/Bugs/Caterpillar/CaterpillarAmount,
	"snail": $OnScreenUI/Bugs/Snail/SnailAmount,
	"moth": $OnScreenUI/Bugs/Moth/MothAmoubt,
	"earthworm": $OnScreenUI/Bugs/Moth/MothAmoubt,
}

func _ready() -> void:
	pause_button.pressed.connect(_on_pause_pressed)
	Upgrades.changed.connect(_update_counts)
	_update_counts()

func _update_counts() -> void:
	for t in count_labels:
		count_labels[t].text = str(Upgrades.bugs[t])

func _on_pause_pressed() -> void:
	get_tree().call_group("pause_menu", "open")
