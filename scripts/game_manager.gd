extends Node

signal scored(amount: int, bug: Enums.type)
signal cooldown_started(duration: float)

var scores = { }

const BASE_COOLDOWN := 1.0
var cooldown_left := 0.0

# Funkcje ograniczająca szybkość klikania (stała do podmiany jak będą upgradey)
func _process(delta: float) -> void:
	cooldown_left = maxf(cooldown_left - delta, 0.0)

func can_catch() -> bool:
	return cooldown_left <= 0.0

func start_cooldown() -> void:
	cooldown_left = BASE_COOLDOWN
	cooldown_started.emit(cooldown_left)

func _init() -> void:
	reset()

func reset() -> void:
	for bug_name in Enums.type:
		scores[bug_name] = 0


# Funkcja do dodawania punktów do UI
func add_point(bug_type: Enums.type) -> void:
	var bug_name = Enums.type.find_key(bug_type)
	scores[bug_name] += 1
	
	scored.emit(scores[bug_name], bug_type)


# Funkcja do zapisywania i wczytywannia gry
func get_save_data() -> Dictionary:
	return {"scores": scores}

func apply_save_data(data: Dictionary) -> void:
	reset()
	var saved: Dictionary = data.get("scores", {})
	for bug_name in saved:
		if scores.has(bug_name):
			scores[bug_name] = int(saved[bug_name])
			scored.emit(scores[bug_name], Enums.type[bug_name])
