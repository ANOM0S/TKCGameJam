extends Control

# Ustawienie kolorków
@export var fill_color := Color(0.162, 0.374, 0.706, 1.0)
@export var bg_color := Color(0, 0, 0, 0.5)
@export var ring_color := Color(0.66, 0.403, 0.416, 1.0)

# pobranie game menagera
@onready var game_manager = %GameManager

# Zmienne
var progress := 1.0   # 1 = gotowe do kliknięcia
var duration := 1.0
var elapsed := 0.0
var running := false


func _ready() -> void:
	pass
	#game_manager.cooldown_started.connect(_on_started)

func _on_started(d: float) -> void:
	duration = maxf(d, 0.01)
	elapsed = 0.0
	running = true

func _process(delta: float) -> void:
	if not running:
		return
	elapsed += delta
	progress = clampf(elapsed / duration, 0.0, 1.0)
	if progress >= 1.0:
		running = false
	queue_redraw()

# Rysowania kółka
func _draw() -> void:
	var c := size / 2.0
	var r := minf(size.x, size.y) / 2.0 - 2.0
	draw_circle(c, r, bg_color)
	if progress > 0.01:
		var pts := PackedVector2Array([c])
		var steps := 64
		for i in steps + 1:
			var a := -PI / 2.0 + TAU * progress * i / steps
			pts.append(c + Vector2(cos(a), sin(a)) * r)
		draw_colored_polygon(pts, fill_color)
	draw_arc(c, r, 0.0, TAU, 64, ring_color, 3.0)
