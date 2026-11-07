extends CharacterBody2D


@export var bugType: Enums.type
@export var speed = 30.0
@export var speed_multiplier = 100.0

enum state { IDLE, MOVE }

var direction: Vector2 = Vector2.ZERO
var current_orientation: Vector2 = Vector2.RIGHT
var current_state: state = state.IDLE

@onready var timer: Timer = $Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: Node = %GameManager


func _ready() -> void:
	_choose_new_direction()
	timer.start()
	timer.timeout.connect(_on_timer_timeout)
	input_event.connect(_on_input_event)


func _process(_delta: float) -> void:
	if direction != Vector2.ZERO: 
		current_orientation = Vector2.RIGHT if direction.x > 0 else Vector2.LEFT
	
	if current_orientation == Vector2.RIGHT:
		animated_sprite_2d.flip_h = false
	elif current_orientation == Vector2.LEFT:
		animated_sprite_2d.flip_h = true
	
	if current_state == state.IDLE:
		animated_sprite_2d.play("IDLE")
	elif current_state == state.MOVE and animated_sprite_2d.sprite_frames.has_animation("MOVE"):
		animated_sprite_2d.play("MOVE")


func _physics_process(delta: float) -> void:
	velocity = direction * speed * speed_multiplier * delta
	
	move_and_slide()
	
	if is_on_wall():
		_choose_new_direction()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			collect()


## removes the bug and adds score in game manager
func collect():
	game_manager.add_point(bugType)
	queue_free()


## sets direction to a randomly rotated normalized Vector2
func _choose_new_direction() -> void:
	var wait_time: float = 1.0
	
	if randf() < 0.05:
		current_state = state.IDLE
		direction = Vector2.ZERO
		wait_time = randf_range(2.0, 3.0)
	else:
		current_state = state.MOVE
		var random_angle = randf_range(0, TAU)
		direction = Vector2.RIGHT.rotated(random_angle)
		wait_time = randf_range(1.0, 2.0)
	
	# restarts the timer whenever the direction changes (so also on wall collision)
	timer.wait_time = wait_time
	timer.start()


## chooses a new direction every time the timer reaches zero
func _on_timer_timeout() -> void:
	_choose_new_direction()
