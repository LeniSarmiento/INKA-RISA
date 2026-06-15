extends Node2D

var current_level: int = 1
var time_passed: float = 0.0
var camera_offset: float = 0.0
var world_width: float = 3000.0

func setup_level(level: int) -> void:
	current_level = clamp(level, 1, 10)
	queue_redraw()

func set_camera_offset(value: float) -> void:
	camera_offset = value
	queue_redraw()

func _process(delta: float) -> void:
	time_passed += delta
	queue_redraw()

func _draw() -> void:
	_draw_pixel_sky()
	draw_set_transform(Vector2(-camera_offset, 0), 0.0, Vector2.ONE)
	_draw_pixel_mountains()
	_draw_pixel_world()
	_draw_level_exit()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_pixel_sky() -> void:
	var sky: Color = Color(0.18, 0.50, 0.75)
	if current_level >= 6:
		sky = Color(0.11, 0.30, 0.55)
	if current_level >= 9:
		sky = Color(0.09, 0.11, 0.26)
	draw_rect(Rect2(0, 0, 1280, 720), sky, true)
	for i in range(10):
		var x: float = fmod(time_passed * (10.0 + i) + i * 190.0 - camera_offset * 0.25, 1450.0) - 120.0
		var y: float = 55.0 + float(i % 3) * 42.0
		_draw_pixel_cloud(Vector2(x, y))
	_draw_pixel_sun(Vector2(1000 - camera_offset * 0.15, 90), 36)

func _draw_pixel_mountains() -> void:
	for i in range(15):
		var x: float = -120.0 + i * 215.0
		var peak: float = 155.0 + float(i % 2) * 45.0
		draw_colored_polygon(PackedVector2Array([Vector2(x, 560), Vector2(x + 135, peak), Vector2(x + 300, 560)]), Color(0.08, 0.18, 0.24, 0.70))
		draw_colored_polygon(PackedVector2Array([Vector2(x + 135, peak), Vector2(x + 108, peak + 70), Vector2(x + 170, peak + 70)]), Color(0.75, 0.86, 0.82, 0.55))

func _draw_pixel_world() -> void:
	var ground_y: float = 650.0
	draw_rect(Rect2(0, ground_y, world_width, 70), Color(0.20, 0.12, 0.06), true)
	draw_rect(Rect2(0, ground_y, world_width, 12), Color(0.09, 0.42, 0.16), true)
	for x in range(0, int(world_width), 32):
		draw_rect(Rect2(x, ground_y + 12, 16, 16), Color(0.30, 0.18, 0.08), true)
		draw_rect(Rect2(x + 16, ground_y + 28, 16, 16), Color(0.15, 0.08, 0.04), true)
	for rect in _platforms():
		_draw_pixel_platform(rect)
	for x in [420, 980, 1440, 2100, 2500]:
		_draw_pixel_temple(Vector2(x, 536))

func _platforms() -> Array[Rect2]:
	return [
		Rect2(260, 565, 130, 22), Rect2(520, 515, 130, 22), Rect2(780, 455, 140, 22),
		Rect2(1060, 540, 130, 22), Rect2(1330, 485, 130, 22), Rect2(1600, 430, 130, 22),
		Rect2(1880, 540, 140, 22), Rect2(2160, 500, 130, 22), Rect2(2440, 455, 130, 22)
	]

func _draw_pixel_platform(rect: Rect2) -> void:
	draw_rect(rect, Color(0.12, 0.45, 0.16), true)
	draw_rect(Rect2(rect.position.x, rect.position.y + 8, rect.size.x, rect.size.y + 18), Color(0.34, 0.19, 0.08), true)
	for x in range(int(rect.position.x), int(rect.position.x + rect.size.x), 24):
		draw_rect(Rect2(x, rect.position.y + 8, 12, rect.size.y + 18), Color(0.22, 0.12, 0.05), true)

func _draw_level_exit() -> void:
	var x: float = 2860.0
	draw_rect(Rect2(x, 552, 28, 98), Color(0.95, 0.72, 0.15), true)
	draw_rect(Rect2(x + 6, 562, 16, 88), Color(0.32, 0.16, 0.08), true)
	draw_rect(Rect2(x - 18, 540, 64, 18), Color(0.95, 0.72, 0.15), true)
	draw_string(ThemeDB.fallback_font, Vector2(x - 50, 532), "META", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1, 0.92, 0.55))

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
