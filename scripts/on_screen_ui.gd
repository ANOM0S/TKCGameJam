extends Control   

# Połączenie z przyciskami i licznikiem robaków
@onready var pause_button: Button = %PauseButton
@onready var go_to_quota: Button = %GoToQuota
@onready var count_labels := {
	Enums.type.Ant: $OnScreenUI/Bugs/Ant/AntAmount,
	Enums.type.Beetle: $OnScreenUI/Bugs/Beetle/BeetleAmount,
	Enums.type.Caterpillar: $OnScreenUI/Bugs/Caterpillar/CaterpillarAmount,
	Enums.type.Earthworm: $OnScreenUI/Bugs/Snail/SnailAmount,
	Enums.type.Moth: $OnScreenUI/Bugs/Moth/MothAmoubt,
	Enums.type.Snail: $OnScreenUI/Bugs/Moth/MothAmoubt,
}

func _ready() -> void:
	pause_button.pressed.connect(_on_pause_pressed)
	var gm := get_tree().current_scene.get_node("%GameManager")
	gm.scored.connect(_on_scored)
	# pokaż stan początkowy
	for bug_type in count_labels:
		var bug_name: String = Enums.type.find_key(bug_type)
		count_labels[bug_type].text = str(gm.scores.get(bug_name, 0))

func _on_scored(amount: int, bug: Enums.type) -> void:
	if count_labels.has(bug):
		count_labels[bug].text = str(amount)

func _on_pause_pressed() -> void:
	get_tree().call_group("pause_menu", "open")



const VIEW_GAME := Vector2(0, 0)
const VIEW_QUOTA := Vector2(0, -1080)

var in_quota := false
var cam_tween: Tween

func _on_go_to_quota_pressed() -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return

	in_quota = not in_quota
	var target := VIEW_QUOTA if in_quota else VIEW_GAME

	# przerwij poprzednią animację, jeśli jeszcze trwa
	if cam_tween and cam_tween.is_running():
		cam_tween.kill()

	cam_tween = create_tween()
	cam_tween.tween_property(cam, "position", target, 1.8) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	%GoToQuota.text = "Wróć do gry" if in_quota else "Do quoty"
