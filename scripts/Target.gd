extends Node2D

signal destroyed(points: int)
signal escaped

var level: int = 1
var speed: float = 40.0
var hit_radius: float = 34.0
var hp: int = 1
var max_hp: int = 1
var points: int = 1
var is_dead: bool = false
var base_y: float = 0.0
var wave_time: float = 0.0
var vertical_amplitude: float = 0.0
var vertical_frequency: float = 1.0
var tint: Color = Color(1.0, 0.66, 0.12)
var is_boss: bool = false
var enemy_kind: String = "sun"
var patrol_left: float = 0.0
var patrol_right: float = 1280.0
var direction: int = -1

func _ready() -> void:
	add_to_group("targets")
	base_y = position.y
	queue_redraw()

func setup(p_level: int, p_speed: float, p_radius: float, p_hp: int) -> void:
	enemy_kind = "sun"
	level = p_level
	speed = p_speed
	hit_radius = p_radius
	hp = p_hp
	max_hp = p_hp
	points = max(1, p_level)
	vertical_amplitude = 8.0 + float(p_level) * 2.6
	vertical_frequency = 0.8 + float(p_level) * 0.12
	tint = Color(1.0, 0.70, 0.10) if level < 6 else Color(1.0, 0.28, 0.12)
	queue_redraw()

func setup_walker(p_level: int, left_x: float, right_x: float, ground_y: float) -> void:
	enemy_kind = "walker"
	level = p_level
	speed = 55.0 + float(p_level) * 8.0
	hit_radius = 24.0
	hp = 1 if p_level < 5 else 2
	max_hp = hp
	points = max(1, p_level)
	patrol_left = left_x
	patrol_right = right_x
	position.x = randf_range(left_x, right_x)
	position.y = ground_y
	base_y = ground_y
	vertical_amplitude = 0.0
	vertical_frequency = 1.0
	direction = -1 if randf() < 0.5 else 1
	queue_redraw()

func setup_boss(p_level: int) -> void:
	is_boss = true
	enemy_kind = "boss"
	level = p_level
	speed = 0.0
	hit_radius = 50.0 + float(min(p_level, 10)) * 1.8
	hp = 8 + p_level * 2
	max_hp = hp
	points = 10 * p_level
	vertical_amplitude = 16.0 + float(p_level) * 1.4
	vertical_frequency = 1.05 + float(p_level) * 0.08
	if p_level <= 3:
		tint = Color(1.0, 0.42, 0.08)
	elif p_level <= 6:
		tint = Color(1.0, 0.18, 0.08)
	elif p_level <= 9:
		tint = Color(0.78, 0.18, 0.90)
	else:
		tint = Color(0.15, 0.95, 1.0)
	queue_redraw()

func _process(delta: float) -> void:
	if is_dead:
		return
	wave_time += delta
	if is_boss:
		position.x = 2760.0 + sin(wave_time * 0.9) * 18.0
		position.y = base_y + sin(wave_time * vertical_frequency) * vertical_amplitude
	elif enemy_kind == "walker":
		position.x += speed * float(direction) * delta
		if position.x <= patrol_left:
			position.x = patrol_left
			direction = 1
		elif position.x >= patrol_right:
			position.x = patrol_right
			direction = -1
		position.y = base_y
	else:
		position.x -= speed * delta
		position.y = base_y + sin(wave_time * vertical_frequency) * vertical_amplitude
		rotation = sin(wave_time * 2.0) * 0.10
	if enemy_kind == "sun" and position.x < -120.0:
		escaped.emit()
		queue_free()
	queue_redraw()

func take_hit() -> void:
	if is_dead:
		return
	hp -= 1
	if hp <= 0:
		is_dead = true
		destroyed.emit(points)
		queue_free()
	else:
		modulate = Color(1, 1, 1, 0.65)
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.12)
		queue_redraw()

func get_hit_radius() -> float:
	return hit_radius

func get_hit_center() -> Vector2:
	if enemy_kind == "walker":
		return position + Vector2(0.0, -34.0)
	if is_boss:
		return position + Vector2(0.0, -6.0)
	return position

func _draw() -> void:
	if enemy_kind == "walker":
		_draw_walker()
		return
	_draw_sun_enemy()

func _draw_sun_enemy() -> void:
	var r = hit_radius
	for i in range(16):
		var a = TAU * float(i) / 16.0
		var p1 = Vector2(cos(a), sin(a)) * (r * 0.62)
		var p2 = Vector2(cos(a), sin(a)) * (r * 1.12)
		draw_line(p1, p2, Color(1.0, 0.82, 0.20, 0.65), 3.0)
	draw_circle(Vector2.ZERO, r, Color(tint.r, tint.g, tint.b, 0.82))
	draw_circle(Vector2.ZERO, r * 0.62, Color(1.0, 0.88, 0.25, 0.95))
	draw_arc(Vector2.ZERO, r + 4.0, 0.0, TAU, 30, Color(0.25, 0.10, 0.03, 0.78), 3.0)
	if max_hp > 1:
		for i in range(min(hp, 8)):
			draw_circle(Vector2(-24 + i * 7, 0), 3.0, Color(0.16, 0.06, 0.02, 0.9))
	if is_boss:
		draw_string(ThemeDB.fallback_font, Vector2(-34, -64), "BOSS", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1.0, 0.92, 0.30))

func _draw_walker() -> void:
	var flip: float = float(direction)
	var step: float = sin(wave_time * 9.0) * 2.0
	draw_rect(Rect2(-14, -6, 28, 5), Color(0, 0, 0, 0.22), true)
	draw_rect(Rect2(-9 - step, -13, 6, 12), Color(0.18, 0.09, 0.05), true)
	draw_rect(Rect2(3 + step, -13, 6, 12), Color(0.18, 0.09, 0.05), true)
	draw_rect(Rect2(-13, -38, 26, 26), Color(0.14, 0.08, 0.05), true)
	draw_rect(Rect2(-11, -36, 22, 21), Color(0.42, 0.16, 0.08), true)
	draw_rect(Rect2(-9, -34, 18, 4), Color(0.95, 0.66, 0.12), true)
	draw_rect(Rect2(-10, -57, 20, 19), Color(0.12, 0.07, 0.05), true)
	draw_rect(Rect2(-8, -55, 16, 15), Color(0.58, 0.28, 0.16), true)
	draw_rect(Rect2(-4, -50, 3, 3), Color(0.02, 0.01, 0.0), true)
	draw_rect(Rect2(3, -50, 3, 3), Color(0.02, 0.01, 0.0), true)
	draw_rect(Rect2(-14, -61, 28, 5), Color(0.78, 0.18, 0.08), true)
	draw_rect(Rect2(-18, -65, 8, 8), Color(0.95, 0.55, 0.12), true)
	draw_rect(Rect2(10, -65, 8, 8), Color(0.05, 0.72, 0.68), true)
	draw_line(Vector2(12.0 * flip, -35), Vector2(28.0 * flip, -28), Color(0.50, 0.24, 0.08), 3.0)
	draw_colored_polygon(PackedVector2Array([Vector2(30.0 * flip, -28), Vector2(39.0 * flip, -31), Vector2(35.0 * flip, -23)]), Color(0.86, 0.82, 0.66))
	if max_hp > 1:
		for i in range(hp):
			draw_rect(Rect2(-8 + i * 8, -72, 5, 5), Color(1.0, 0.18, 0.10), true)
