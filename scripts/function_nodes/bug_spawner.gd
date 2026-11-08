extends Node2D

const bug_scene_path := "res://scenes/bugs"

var bug_scenes := { }

@onready var game_manager: Node = %GameManager
@onready var bugs: Node2D = $Bugs


func _ready() -> void:
	_load_scenes()


func spawn(bug_type: Enums.type, bug_position: Vector2) -> void:
	var bug_name = Enums.type.find_key(bug_type)
	var bug_scene: PackedScene = bug_scenes[bug_name]
	var bug: CharacterBody2D = bug_scene.instantiate()
	
	bugs.add_child(bug)
	bug.global_position = bug_position
	


func _load_scenes() -> void:
	var file_list: Array = Array(
			ResourceLoader.list_directory(bug_scene_path)
		).filter(
			func (fp: String) -> bool: return fp.ends_with(".tscn")
		)
	
	for bug_name: String in Enums.type:
		print(bug_name)
		var index: int = file_list.find(bug_name.to_lower() + ".tscn")
		if index != -1:
			bug_scenes[bug_name] = load(bug_scene_path + "/" + file_list[index])
		else:
			push_warning("Couldn't find file for ", bug_name)
