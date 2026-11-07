extends Node

var scores = { }

signal scored(amount: int, bug: Enums.type)


func _ready() -> void:
	for bug_name in Enums.type:
		scores[bug_name] = 0


func add_point(bug_type: Enums.type) -> void:
	var bug_name = Enums.type.find_key(bug_type)
	scores[bug_name] += 1
	
	scored.emit(scores[bug_name], bug_type)
