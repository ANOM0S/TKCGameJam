extends Control   

# Połączenie z przyciskami i licznikiem robaków
@onready var pause_button: TextureButton = %PauseButton
@onready var go_to_quota: TextureButton = %GoToQuota
@onready var count_label: Label = $OnScreenUI/Bugs/BugAmount

func _ready() -> void:
	pause_button.pressed.connect(_on_pause_pressed)
	var gm := get_tree().current_scene.get_node("%GameManager")
	gm.scored.connect(_on_scored)
	count_label.text = str(0)

func _on_scored(amount: int) -> void:
	count_label.text = str(amount)

func _on_pause_pressed() -> void:
	get_tree().call_group("pause_menu", "open")


const VIEW_GAME := Vector2(0, 0)
const VIEW_QUOTA := Vector2(0, -1080)

var in_quota := false
var cam_tween: Tween
func swapScreen() -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return

	in_quota = not in_quota
	var target := VIEW_QUOTA if in_quota else VIEW_GAME

	if cam_tween and cam_tween.is_running():
		cam_tween.kill()

	cam_tween = create_tween()
	cam_tween.tween_property(cam, "position", target, 1.8) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	%GoToQuota.flip_v = false if in_quota else true

func _on_go_to_quota_pressed() -> void:
	swapScreen()
