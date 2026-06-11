extends Node2D

var current_level: int = 1
var time_passed: float = 0.0

func setup_level(level: int) -> void:
	current_level = clamp(level, 1, 10)
	queue_redraw()

func _process(delta: float) -> void:
	time_passed += delta
	queue_redraw()

func _draw() -> void:
	_draw_pixel_sky()
	_draw_pixel_mountains()
	_draw_pixel_world()
	_draw_level_exit()

func _draw_pixel_sky() -> void:
	var sky: Color = Color(0.18, 0.50, 0.75)
	if current_level >= 6:
		sky = Color(0.11, 0.30, 0.55)
	if current_level >= 9:
		sky = Color(0.09, 0.11, 0.26)
	draw_rect(Rect2(0, 0, 1280, 720), sky, true)
	for i in range(8):
		var x: float = fmod(time_passed * (12.0 + i) + i * 180.0, 1420.0) - 90.0
		var y: float = 60.0 + float(i % 3) * 38.0
		_draw_pixel_cloud(Vector2(x, y))
	_draw_pixel_sun(Vector2(1000, 100), 36)

func _draw_pixel_mountains() -> void:
	for i in range(7):
		var x: float = -80.0 + i * 210.0
		var peak: float = 155.0 + float(i % 2) * 45.0
		draw_colored_polygon(PackedVector2Array([Vector2(x, 560), Vector2(x + 135, peak), Vector2(x + 300, 560)]), Color(0.08, 0.18, 0.24, 0.70))
		draw_colored_polygon(PackedVector2Array([Vector2(x + 135, peak), Vector2(x + 108, peak + 70), Vector2(x + 170, peak + 70)]), Color(0.75, 0.86, 0.82, 0.55))

func _draw_pixel_world() -> void:
	var ground_y: float = 650.0
	draw_rect(Rect2(0, ground_y, 1280, 70), Color(0.20, 0.12, 0.06), true)
	draw_rect(Rect2(0, ground_y, 1280, 12), Color(0.09, 0.42, 0.16), true)
	for x in range(0, 1280, 32):
		draw_rect(Rect2(x, ground_y + 12, 16, 16), Color(0.30, 0.18, 0.08), true)
		draw_rect(Rect2(x + 16, ground_y + 28, 16, 16), Color(0.15, 0.08, 0.04), true)
	var platforms: Array[Rect2] = [
		Rect2(270, 565, 120, 22), Rect2(500, 510, 120, 22), Rect2(720, 455, 132, 22),
		Rect2(935, 540, 118, 22), Rect2(1080, 450, 112, 22)
	]
	for i in range(platforms.size()):
		if current_level + 2 >= i:
			_draw_pixel_platform(platforms[i])
	_draw_pixel_temple(Vector2(1120, 536))

func _draw_pixel_platform(rect: Rect2) -> void:
	draw_rect(rect, Color(0.12, 0.45, 0.16), true)
	draw_rect(Rect2(rect.position.x, rect.position.y + 8, rect.size.x, rect.size.y + 18), Color(0.34, 0.19, 0.08), true)
	for x in range(int(rect.position.x), int(rect.position.x + rect.size.x), 24):
		draw_rect(Rect2(x, rect.position.y + 8, 12, rect.size.y + 18), Color(0.22, 0.12, 0.05), true)

func _draw_level_exit() -> void:
	var x: float = 1210.0
	draw_rect(Rect2(x, 552, 28, 98), Color(0.95, 0.72, 0.15), true)
	draw_rect(Rect2(x + 6, 562, 16, 88), Color(0.32, 0.16, 0.08), true)
	draw_rect(Rect2(x - 18, 540, 64, 18), Color(0.95, 0.72, 0.15), true)
	draw_string(ThemeDB.fallback_font, Vector2(1160, 532), "META", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1, 0.92, 0.55))

func _draw_pixel_cloud(pos: Vector2) -> void:
	draw_rect(Rect2(pos.x, pos.y, 74, 16), Color(1, 1, 1, 0.30), true)
	draw_rect(Rect2(pos.x + 18, pos.y - 14, 34, 30), Color(1, 1, 1, 0.30), true)
	draw_rect(Rect2(pos.x + 54, pos.y + 4, 32, 12), Color(1, 1, 1, 0.30), true)

func _draw_pixel_sun(pos: Vector2, r: int) -> void:
	draw_rect(Rect2(pos.x - r, pos.y - r, r * 2, r * 2), Color(1.0, 0.78, 0.18, 0.18), true)
	draw_circle(pos, r, Color(1.0, 0.82, 0.20, 0.75))
	draw_circle(pos, r * 0.55, Color(1.0, 0.95, 0.42, 0.95))

func _draw_pixel_temple(pos: Vector2) -> void:
	draw_rect(Rect2(pos.x, pos.y, 88, 114), Color(0.34, 0.20, 0.09), true)
	draw_rect(Rect2(pos.x - 16, pos.y - 18, 120, 22), Color(0.47, 0.30, 0.11), true)
	draw_rect(Rect2(pos.x + 34, pos.y + 48, 28, 66), Color(0.05, 0.03, 0.02), true)
