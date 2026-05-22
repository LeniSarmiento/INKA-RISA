extends Node2D

const GAME_BACKGROUND: Texture2D = preload("res://assets/images/background_game.jpg")
const BANNER_RUN: Texture2D = preload("res://assets/images/banner_run.jpg")

var scroll_x: float = 0.0
var show_banner: bool = false

func _process(delta: float) -> void:
	# Parallax suave para dar sensación de avance.
	scroll_x = fmod(scroll_x + 22.0 * delta, 1280.0)
	queue_redraw()

func _draw() -> void:
	var screen := Vector2(1280, 720)
	var tex := BANNER_RUN if show_banner else GAME_BACKGROUND
	draw_texture_rect(tex, Rect2(Vector2.ZERO, screen), false)

	# Capa oscura ligera para que el HUD y proyectiles se lean mejor.
	draw_rect(Rect2(Vector2.ZERO, screen), Color(0.02, 0.025, 0.03, 0.20), true)

	# Piso y caminos andinos.
	draw_rect(Rect2(Vector2(0, 650), Vector2(1280, 70)), Color(0.21, 0.13, 0.08, 0.72), true)
	for i in range(16):
		var x := float(i * 95) - scroll_x * 0.55
		while x < -100.0:
			x += 1520.0
		draw_polygon(PackedVector2Array([
			Vector2(x, 658), Vector2(x + 70, 658), Vector2(x + 86, 705), Vector2(x - 10, 705)
		]), PackedColorArray([Color(0.56, 0.42, 0.25, 0.75), Color(0.56, 0.42, 0.25, 0.75), Color(0.40, 0.28, 0.15, 0.75), Color(0.40, 0.28, 0.15, 0.75)]))

	# Espiral Fibonacci decorativa para reforzar la temática matemática.
	_draw_fibonacci_spiral(Vector2(1035, 150), 7.0, Color(1.0, 0.74, 0.19, 0.28))

func _draw_fibonacci_spiral(origin: Vector2, unit: float, color: Color) -> void:
	var fib := [1, 1, 2, 3, 5, 8, 13]
	var angle := 0.0
	var pos := origin
	for n in fib:
		var radius := float(n) * unit
		draw_arc(pos, radius, angle, angle + PI / 2.0, 18, color, 2.0)
		pos += Vector2(cos(angle + PI / 2.0), sin(angle + PI / 2.0)) * radius * 0.55
		angle += PI / 2.0
