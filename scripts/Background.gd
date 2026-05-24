extends Node2D

# Fondo por capas para InkaRise.
# Cada nivel cambia colores, ruinas, plataformas, vegetación y efectos ambientales.

var current_level: int = 1
var time_passed: float = 0.0

func setup_level(level: int) -> void:
	current_level = clamp(level, 1, 10)
	queue_redraw()

func _process(delta: float) -> void:
	time_passed += delta
	queue_redraw()

func _draw() -> void:
	_draw_sky_layer()
	_draw_cloud_layer()
	_draw_mountain_layer()
	_draw_ruins_layer()
	_draw_platform_layer()
	_draw_environment_details()
	_draw_front_layer()

func _draw_sky_layer() -> void:
	var sky_color: Color = Color(0.18, 0.52, 0.76)
	var horizon_color: Color = Color(0.34, 0.66, 0.78)
	if current_level >= 5:
		sky_color = Color(0.13, 0.38, 0.58)
		horizon_color = Color(0.24, 0.50, 0.63)
	if current_level >= 8:
		sky_color = Color(0.09, 0.16, 0.30)
		horizon_color = Color(0.16, 0.25, 0.42)
	if current_level >= 10:
		sky_color = Color(0.12, 0.06, 0.16)
		horizon_color = Color(0.25, 0.12, 0.24)

	draw_rect(Rect2(0, 0, 1280, 720), sky_color, true)
	draw_rect(Rect2(0, 250, 1280, 250), horizon_color, true)

	var sun_pos: Vector2 = Vector2(990, 110)
	if current_level >= 8:
		sun_pos = Vector2(1085, 135)
	_draw_inti_sun(sun_pos, 34.0 + float(current_level) * 1.2)

func _draw_cloud_layer() -> void:
	for i in range(7):
		var x: float = fmod(time_passed * (9.0 + float(i % 3) * 2.0) + float(i) * 215.0, 1460.0) - 130.0
		var y: float = 55.0 + float(i % 4) * 33.0 + sin(time_passed * 0.7 + float(i)) * 8.0
		_draw_cloud(Vector2(x, y), 0.85 + float(i % 3) * 0.18)

func _draw_mountain_layer() -> void:
	for i in range(8):
		var x: float = float(i) * 210.0 - 120.0
		var peak_y: float = 155.0 + float(i % 3) * 42.0
		var color_far: Color = Color(0.09, 0.20, 0.27, 0.65)
		if current_level >= 7:
			color_far = Color(0.08, 0.13, 0.22, 0.74)
		var far_points: PackedVector2Array = PackedVector2Array([
			Vector2(x, 450), Vector2(x + 145, peak_y), Vector2(x + 300, 450)
		])
		draw_colored_polygon(far_points, color_far)
		var snow_points: PackedVector2Array = PackedVector2Array([
			Vector2(x + 145, peak_y), Vector2(x + 110, peak_y + 70), Vector2(x + 180, peak_y + 70)
		])
		draw_colored_polygon(snow_points, Color(0.84, 0.92, 0.91, 0.40))

	for j in range(6):
		var xx: float = float(j) * 250.0 - 80.0
		var yy: float = 265.0 + float(j % 2) * 35.0
		var near_points: PackedVector2Array = PackedVector2Array([
			Vector2(xx, 520), Vector2(xx + 130, yy), Vector2(xx + 315, 520)
		])
		draw_colored_polygon(near_points, Color(0.07, 0.17, 0.18, 0.50))

func _draw_ruins_layer() -> void:
	if current_level <= 2:
		_draw_temple(Vector2(760, 332), 0.82, false)
		_draw_small_ruin(Vector2(1010, 365))
	elif current_level <= 4:
		_draw_temple(Vector2(690, 292), 1.02, false)
		_draw_small_ruin(Vector2(1030, 360))
	elif current_level <= 6:
		_draw_temple(Vector2(668, 270), 1.08, false)
		_draw_rebound_zone(Vector2(920, 350))
	elif current_level <= 8:
		_draw_temple(Vector2(650, 250), 1.12, false)
		_draw_magic_tree(Vector2(1050, 268))
	else:
		_draw_final_temple(Vector2(790, 235))
		_draw_red_warning(Vector2(1120, 240))

func _draw_platform_layer() -> void:
	# Plataformas flotantes centrales.
	var platforms: Array[Vector2] = [Vector2(680, 600), Vector2(945, 545), Vector2(1090, 635), Vector2(520, 540)]
	for i in range(platforms.size()):
		if current_level >= i + 1:
			_draw_floating_platform(platforms[i], 0.9 + float(i) * 0.13)

	# Piso principal.
	var ground_y: float = 650.0
	draw_rect(Rect2(0, ground_y, 1280, 70), Color(0.23, 0.15, 0.08, 0.80), true)
	draw_rect(Rect2(0, ground_y, 1280, 14), Color(0.13, 0.38, 0.14, 0.95), true)
	for i in range(18):
		var x: float = float(i) * 77.0
		var triangle: PackedVector2Array = PackedVector2Array([
			Vector2(x, ground_y), Vector2(x + 54, ground_y), Vector2(x + 26, ground_y + 44)
		])
		draw_colored_polygon(triangle, Color(0.42, 0.27, 0.12, 0.82))

func _draw_environment_details() -> void:
	# Antorchas y vegetación.
	var torch_positions: Array[Vector2] = [Vector2(120, 612), Vector2(330, 615), Vector2(930, 610), Vector2(1140, 610)]
	for pos in torch_positions:
		_draw_torch(pos)

	for i in range(22):
		var x: float = 24.0 + float(i) * 62.0
		var y: float = 640.0 + sin(float(i) * 1.65) * 9.0
		draw_circle(Vector2(x, y), 12.0, Color(0.06, 0.28, 0.11, 0.70))
		draw_circle(Vector2(x + 12.0, y + 2.0), 9.0, Color(0.08, 0.38, 0.15, 0.58))

	# Ornamentos según zona.
	if current_level >= 3:
		_draw_golden_symbol(Vector2(210, 190), 0.65)
	if current_level >= 5:
		_draw_golden_symbol(Vector2(1040, 185), 0.80)
	if current_level >= 7:
		_draw_fibonacci_spiral(Vector2(1015, 155), 7.0, Color(1.0, 0.72, 0.18, 0.24))
	if current_level >= 9:
		_draw_golden_symbol(Vector2(540, 185), 0.90)

func _draw_front_layer() -> void:
	# Viñeta suave para que el HUD sea legible.
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.0, 0.0, 0.0, 0.16), true)
	# Franja ambiental inferior.
	draw_rect(Rect2(0, 640, 1280, 80), Color(0.05, 0.03, 0.02, 0.14), true)

func _draw_inti_sun(pos: Vector2, radius: float) -> void:
	draw_circle(pos, radius * 1.9, Color(1.0, 0.72, 0.10, 0.12))
	for i in range(16):
		var a: float = float(i) * TAU / 16.0
		draw_line(pos + Vector2(cos(a), sin(a)) * radius, pos + Vector2(cos(a), sin(a)) * (radius + 22.0), Color(1.0, 0.74, 0.16, 0.32), 2.0)
	draw_circle(pos, radius, Color(1.0, 0.67, 0.10, 0.70))
	draw_circle(pos, radius * 0.55, Color(1.0, 0.94, 0.38, 0.90))

func _draw_cloud(pos: Vector2, scale: float) -> void:
	var cloud_color: Color = Color(1.0, 1.0, 1.0, 0.28)
	draw_circle(pos, 20.0 * scale, cloud_color)
	draw_circle(pos + Vector2(26, -8) * scale, 28.0 * scale, cloud_color)
	draw_circle(pos + Vector2(58, 1) * scale, 21.0 * scale, cloud_color)
	draw_rect(Rect2(pos.x - 3.0 * scale, pos.y - 1.0 * scale, 72.0 * scale, 14.0 * scale), cloud_color, true)

func _draw_temple(pos: Vector2, scale: float, final_temple: bool) -> void:
	for i in range(6):
		var offset: float = float(i) * 11.0 * scale
		var w: float = (150.0 - float(i) * 18.0) * scale
		var h: float = 26.0 * scale
		var y: float = pos.y + float(i) * 28.0 * scale
		draw_rect(Rect2(pos.x + offset, y, w, h), Color(0.38, 0.27, 0.15, 0.90), true)
		draw_rect(Rect2(pos.x + offset, y, w, 4.0 * scale), Color(0.90, 0.61, 0.18, 0.70), true)
	var door: Rect2 = Rect2(pos.x + 52.0 * scale, pos.y + 138.0 * scale, 40.0 * scale, 58.0 * scale)
	draw_rect(door, Color(0.03, 0.02, 0.015, 0.92), true)
	if final_temple:
		draw_circle(pos + Vector2(95, 42) * scale, 38.0 * scale, Color(1.0, 0.05, 0.05, 0.25))
		draw_string(ThemeDB.fallback_font, pos + Vector2(45, 50) * scale, "JEFE", HORIZONTAL_ALIGNMENT_LEFT, -1, int(22 * scale), Color(1.0, 0.22, 0.18))

func _draw_final_temple(pos: Vector2) -> void:
	_draw_temple(pos, 1.28, true)
	_draw_golden_symbol(pos + Vector2(110, 0), 0.78)

func _draw_small_ruin(pos: Vector2) -> void:
	draw_rect(Rect2(pos.x, pos.y, 105, 135), Color(0.32, 0.24, 0.15, 0.78), true)
	draw_rect(Rect2(pos.x + 12, pos.y + 18, 78, 20), Color(0.72, 0.55, 0.20, 0.68), true)
	draw_rect(Rect2(pos.x + 34, pos.y + 76, 34, 60), Color(0.04, 0.03, 0.02, 0.90), true)

func _draw_rebound_zone(pos: Vector2) -> void:
	for i in range(3):
		var rect: Rect2 = Rect2(pos.x + float(i) * 38.0, pos.y + float(i) * 14.0, 24, 132)
		draw_rect(rect, Color(0.95, 0.64, 0.14, 0.62), true)
		draw_rect(rect, Color(1.0, 0.82, 0.28, 0.82), false, 2.0)

func _draw_magic_tree(pos: Vector2) -> void:
	draw_rect(Rect2(pos.x, pos.y + 85, 38, 145), Color(0.25, 0.13, 0.05, 0.78), true)
	draw_circle(pos + Vector2(18, 58), 76, Color(0.08, 0.32, 0.13, 0.75))
	for i in range(3):
		draw_circle(pos + Vector2(10 + float(i) * 31, 36), 12, Color(1.0, 0.70, 0.10, 0.82))

func _draw_floating_platform(center: Vector2, scale: float) -> void:
	var w: float = 130.0 * scale
	var top: Rect2 = Rect2(center.x - w / 2.0, center.y - 18.0, w, 22.0)
	draw_rect(top, Color(0.18, 0.42, 0.14, 0.78), true)
	draw_rect(Rect2(center.x - w / 2.0, center.y, w, 34.0 * scale), Color(0.20, 0.13, 0.08, 0.78), true)
	var bottom: PackedVector2Array = PackedVector2Array([
		Vector2(center.x - w / 2.0, center.y + 34.0 * scale),
		Vector2(center.x + w / 2.0, center.y + 34.0 * scale),
		Vector2(center.x + w * 0.25, center.y + 78.0 * scale),
		Vector2(center.x - w * 0.20, center.y + 82.0 * scale)
	])
	draw_colored_polygon(bottom, Color(0.20, 0.13, 0.09, 0.70))

func _draw_torch(pos: Vector2) -> void:
	draw_rect(Rect2(pos.x - 3, pos.y, 6, 34), Color(0.35, 0.19, 0.07, 0.88), true)
	draw_circle(pos + Vector2(0, -8), 9, Color(1.0, 0.50, 0.05, 0.90))
	draw_circle(pos + Vector2(0, -8), 18, Color(1.0, 0.50, 0.05, 0.15))

func _draw_golden_symbol(pos: Vector2, scale: float) -> void:
	var r: float = 30.0 * scale
	draw_circle(pos, r, Color(1.0, 0.68, 0.10, 0.16))
	draw_circle(pos, r * 0.58, Color(1.0, 0.75, 0.18, 0.62))
	draw_line(pos + Vector2(-r * 1.25, 0), pos + Vector2(r * 1.25, 0), Color(1.0, 0.75, 0.18, 0.60), 2.0)
	draw_line(pos + Vector2(0, -r * 1.25), pos + Vector2(0, r * 1.25), Color(1.0, 0.75, 0.18, 0.60), 2.0)

func _draw_red_warning(pos: Vector2) -> void:
	draw_circle(pos, 26, Color(1.0, 0.05, 0.05, 0.25))
	draw_string(ThemeDB.fallback_font, pos + Vector2(-9, 9), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color(1.0, 0.22, 0.15))

func _draw_fibonacci_spiral(origin: Vector2, unit: float, color: Color) -> void:
	var fib: Array[int] = [1, 1, 2, 3, 5, 8, 13]
	var angle: float = 0.0
	var pos: Vector2 = origin
	for n in fib:
		var radius: float = float(n) * unit
		draw_arc(pos, radius, angle, angle + PI / 2.0, 18, color, 2.0)
		pos += Vector2(cos(angle + PI / 2.0), sin(angle + PI / 2.0)) * radius * 0.55
		angle += PI / 2.0
