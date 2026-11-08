extends Node


@export var default_spawn_interval: float = 4.0

var scores = { }

signal scored(amount: int, bug: Enums.type)
signal cooldown_started(duration: float)   # DODANE

const BASE_COOLDOWN := 1.0                 # DODANE
var cooldown_left := 0.0                   # DODANE

@onready var bug_spawner: Node2D = %BugSpawner
@onready var bug_spawner_area: CollisionShape2D = %BugSpawner/Area2D/CollisionShape2D
@onready var spawn_timer: Timer = $SpawnTimer


func _ready() -> void:
	for bug_name in Enums.type:
		scores[bug_name] = 0
	
	spawn_timer.wait_time = default_spawn_interval
	spawn_timer.start()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _process(delta: float) -> void:       # DODANE
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


func add_point(bug_type: Enums.type) -> void:
	var bug_name = Enums.type.find_key(bug_type)
	scores[bug_name] += 1
	
	scored.emit(scores[bug_name], bug_type)
	
	# --- cooldown klikania ---
func can_catch() -> bool:
	return cooldown_left <= 0.0

func start_cooldown() -> void:
	cooldown_left = BASE_COOLDOWN
	cooldown_started.emit(cooldown_left)
