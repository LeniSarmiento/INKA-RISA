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

func _ready() -> void:
	add_to_group("targets")
	base_y = position.y
	queue_redraw()

func setup(p_level: int, p_speed: float, p_radius: float, p_hp: int) -> void:
	level = p_level
	speed = p_speed
	hit_radius = p_radius
	hp = p_hp
	max_hp = p_hp
	points = max(1, p_level)
	vertical_amplitude = 8.0 + float(p_level) * 3.2
	vertical_frequency = 0.8 + float(p_level) * 0.15
	# A partir del nivel 6 se vuelven más peligrosos visualmente.
	tint = Color(1.0, 0.70, 0.10) if level < 6 else Color(1.0, 0.28, 0.12)
	queue_redraw()

func _process(delta: float) -> void:
	if is_dead:
		return
	wave_time += delta
	position.x -= speed * delta
	position.y = base_y + sin(wave_time * vertical_frequency) * vertical_amplitude
	rotation = sin(wave_time * 2.0) * 0.10
	if position.x < -70.0:
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

func _draw() -> void:
	# Fragmento de la Energía del Inti / enemigo circular.
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
		# Indicador de resistencia sin depender de fuentes externas.
		for i in range(hp):
			draw_circle(Vector2(-8 + i * 8, 0), 3.0, Color(0.16, 0.06, 0.02, 0.9))
