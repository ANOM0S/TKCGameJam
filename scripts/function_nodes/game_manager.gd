extends Node


@export var default_spawn_interval: float = 4.0
@export var day_length: float = 10.0
@export var quota: int = 5

var score : int = 0

signal scored(amount: int)
signal cooldown_started(duration: float)


const ENDGAME_SCENE := "res://Scenes/Endgame.tscn"
const BASE_COOLDOWN := 1.0
var cooldown_left := 0.0

@onready var bug_spawner: Node2D = %BugSpawner
@onready var bug_spawner_area: CollisionShape2D = %BugSpawner/Area2D/CollisionShape2D
@onready var spawn_timer: Timer = $SpawnTimer
@onready var day_timer: Timer = $DayTimer
@onready var swapScreenButton: TextureButton = $"../CanvasLayer/OnScreenUI/OnScreenUI/GoToQuota"
@onready var on_screen_ui: Control = $"../CanvasLayer/OnScreenUI"


func _ready() -> void:
	score = 0
	
	spawn_timer.wait_time = default_spawn_interval
	spawn_timer.start()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	day_timer.wait_time = day_length
	day_timer.start()
	day_timer.timeout.connect(_on_day_timer_timeout)

func _process(delta: float) -> void:
	cooldown_left = maxf(cooldown_left - delta, 0.0)

func _on_spawn_timer_timeout() -> void:
	var rect = bug_spawner_area.shape as RectangleShape2D
	var extents: Vector2 = rect.size * 0.5
	var random_offset := Vector2(
		randf_range(-extents.x, extents.x),
		randf_range(-extents.y, extents.y)
	)
	
	var bug_position: Vector2 = bug_spawner_area.global_position + random_offset
	bug_spawner.spawn(Enums.type[Enums.type.keys()[randi() % Enums.type.size()]], bug_position)

func _on_day_timer_timeout() -> void:
	if on_screen_ui.in_quota == false:
		on_screen_ui.swapScreen()
	day_timer.stop()
	swapScreenButton.disabled = true


func _pay_a_quota() -> void:
	if score > quota:
		score -= quota
		quota += quota
		swapScreenButton.disabled = false
		day_timer.start()
	elif (day_timer.time_left > 0):
		pass
	else :
		get_tree().change_scene_to_file(ENDGAME_SCENE)

# Dodawanie wartości do złapanych ptaków
func add_point() -> void:
	score += 1
	scored.emit(score)

# Zarządzanie opóźnieniem klikania
func can_catch() -> bool:
	return cooldown_left <= 0.0

func start_cooldown() -> void:
	cooldown_left = BASE_COOLDOWN
	cooldown_started.emit(cooldown_left)
