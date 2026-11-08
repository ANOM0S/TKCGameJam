extends Node

@export var default_spawn_interval: float = 4.0
@export var day_length: float = 10.0
@export var quota: int = 5
@export var max_bug_count: int = 20

var score : int = 0

signal scored(amount: int)
signal cooldown_started(duration: float)

const ENDGAME_SCENE := "res://Scenes/Endgame.tscn"
var upgrade_levels = { }

@export var BASE_COOLDOWN := 1.0
const MIN_COOLDOWN := 0.1
const COOLDOWN_MULTIPLIER := 0.8
var cooldown_left := 0.0

@export var BASE_SPAWNRATE := 5.0 
const MIN_SPAWNRATE_MULTIPLIER := 0.1
const SPAWNRATE_MULTIPLIER := 0.8

const BASE_RANDOM_COOLDOWN := 5.0
const MIN_RANDOM_COOLDOWN := 0.1
const RANDOM_COOLDOWN_MULTIPLIER := 0.8
var random_cooldown_left := 0.0

const BASE_DUPLICATION_CHANCE := 0.05
const MAX_DUPLICATION_CHANCE := 0.25
const DUPLICATION_CHANCE_MULTIPLIER := 0.8

const BASE_MULTIPLICATION_CHANCE := 0.1
const MAX_MULTIPLICATION_CHANCE := 0.50
const MULTIPLICATION_CHANCE_MULTIPLIER := 0.8

@onready var bug_spawner: Node2D = %BugSpawner
@onready var bug_spawner_area: CollisionShape2D = %BugSpawner/Area2D/CollisionShape2D
@onready var bugs_node: Node = %BugSpawner/Bugs
@onready var spawn_timer: Timer = $SpawnTimer
@onready var day_timer: Timer = $DayTimer
@onready var swapScreenButton: TextureButton = $"../CanvasLayer/OnScreenUI/OnScreenUI/GoToQuota"
@onready var on_screen_ui: Control = $"../CanvasLayer/OnScreenUI"


func _ready() -> void:
	score = 0
	
	for upgrade_name in Enums.upgrade:
		upgrade_levels[upgrade_name] = 0
	
	spawn_timer.wait_time = BASE_SPAWNRATE
	spawn_timer.start()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	day_timer.wait_time = day_length
	day_timer.start()
	day_timer.timeout.connect(_on_day_timer_timeout)

func _process(delta: float) -> void:
	cooldown_left = maxf(cooldown_left - delta, 0.0)
	
	if get_upgrade_level(Enums.upgrade.RANDOM_COLLECTION) > 0:
		random_cooldown_left = maxf(random_cooldown_left - delta, 0.0)
		
		if random_cooldown_left == 0.0:
			collect_random()

func _on_spawn_timer_timeout() -> void:
	var bug_count = bugs_node.get_child_count()
	if bug_count >= max_bug_count: return
	
	var rect = bug_spawner_area.shape as RectangleShape2D
	var extents: Vector2 = rect.size * 0.5
	var random_offset := Vector2(
		randf_range(-extents.x, extents.x),
		randf_range(-extents.y, extents.y)
	)
	
	var bug_position: Vector2 = bug_spawner_area.global_position + random_offset
	bug_spawner.spawn(Enums.type[Enums.type.keys()[randi() % Enums.type.size()]], bug_position)
	
	spawn_timer.wait_time = BASE_SPAWNRATE * get_bug_spawnrate()
	spawn_timer.start()


# UPGRADES
func upgrade(upgrade_type: Enums.upgrade) -> void:
	var upgrade_name = Enums.upgrade.find_key(upgrade_type)
	upgrade_levels[upgrade_name] += 1

func get_upgrade_level(upgrade_type: Enums.upgrade) -> int:
	var upgrade_name = Enums.upgrade.find_key(upgrade_type)
	return upgrade_levels[upgrade_name]

func get_collect_cooldown() -> float:
	var upgrade_level = get_upgrade_level(Enums.upgrade.COOLDOWN_REDUCE)
	return max(BASE_COOLDOWN * pow(COOLDOWN_MULTIPLIER, 1 + upgrade_level), MIN_COOLDOWN)

func get_bug_spawnrate() -> float:
	var upgrade_level = get_upgrade_level(Enums.upgrade.HIGHER_SPAWNRATE)
	return max(BASE_SPAWNRATE * pow(SPAWNRATE_MULTIPLIER, upgrade_level), MIN_SPAWNRATE_MULTIPLIER)

func get_collect_random_cooldown() -> float:
	var upgrade_level = get_upgrade_level(Enums.upgrade.RANDOM_COLLECTION)
	return max(BASE_RANDOM_COOLDOWN * pow(RANDOM_COOLDOWN_MULTIPLIER, upgrade_level), MIN_RANDOM_COOLDOWN)

func get_multiplication_chance() -> float:
	var upgrade_level = get_upgrade_level(Enums.upgrade.BUG_MULTIPLIER)
	if upgrade_level < 1: return 0.0
	
	var chance := MAX_MULTIPLICATION_CHANCE - (MAX_MULTIPLICATION_CHANCE - BASE_MULTIPLICATION_CHANCE) * pow(MULTIPLICATION_CHANCE_MULTIPLIER, upgrade_level)
	return min(chance, MAX_MULTIPLICATION_CHANCE)

func get_duplication_chance() -> float:
	var upgrade_level = get_upgrade_level(Enums.upgrade.DUPLICATION)
	if upgrade_level < 1: return 0.0
	
	var chance := MAX_DUPLICATION_CHANCE - (MAX_DUPLICATION_CHANCE - BASE_DUPLICATION_CHANCE) * pow(DUPLICATION_CHANCE_MULTIPLIER, upgrade_level)
	return min(chance, MAX_DUPLICATION_CHANCE)
	

func collect_random() -> void:
	if get_upgrade_level(Enums.upgrade.RANDOM_COLLECTION) < 1:
		return
	
	var bug_node_children = bugs_node.get_children()
	var random_bug = bug_node_children[randi() % bug_node_children.size()]
	
	random_bug.collect()
	start_random_cooldown()

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
	score += (1 + get_upgrade_level(Enums.upgrade.BUG_PLUS_ONE)) * (2 if randf() < get_multiplication_chance() else 1)
	
	scored.emit(score)
	
# Zarządzanie opóźnieniem klikania
func can_catch() -> bool:
	return cooldown_left <= 0.0

func start_cooldown() -> void:
	cooldown_left = get_collect_cooldown()
	cooldown_started.emit(cooldown_left)

func start_random_cooldown() -> void:
	random_cooldown_left = get_collect_random_cooldown()
	#random_cooldown_started.emit(random_cooldown_left)
