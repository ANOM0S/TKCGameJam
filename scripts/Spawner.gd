extends Node2D

@export var worm_scene: PackedScene
@export var worm_types: Array[BugStats]

func _ready() -> void:
	$Timer.timeout.connect(_spawn_worm)

func _spawn_worm() -> void:
	var worm = worm_scene.instantiate()
	var from_left := randf() < 0.5
	worm.position = Vector2(-50 if from_left else 1230, randf_range(100, 600))
	add_child(worm)   # najpierw add_child, żeby zadziałały @onready
	var dir := Vector2(1 if from_left else -1, randf_range(-0.2, 0.2))
	worm.setup(worm_types.pick_random(), dir)
