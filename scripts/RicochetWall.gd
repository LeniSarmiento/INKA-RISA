extends Node2D

var wall_size: Vector2 = Vector2(28, 180)
var wall_label: String = "Muro Inti"
var wall_color: Color = Color(0.72, 0.45, 0.18, 0.84)

# Movimiento de las tablas de rebote.
# Sirve para que las superficies ayuden a redirigir proyectiles y sea más visible la mecánica EE3.
var base_position: Vector2 = Vector2.ZERO
var movement_axis: Vector2 = Vector2.ZERO
var movement_amplitude: float = 0.0
var movement_speed: float = 1.0
var time_passed: float = 0.0
var moving_enabled: bool = false

func _ready() -> void:
	add_to_group("ricochet_walls")
	base_position = position
	queue_redraw()

func _process(delta: float) -> void:
	if not moving_enabled:
		return
	time_passed += delta
	var offset_value: float = sin(time_passed * movement_speed) * movement_amplitude
	position = base_position + movement_axis.normalized() * offset_value
	queue_redraw()

func setup(p_size: Vector2, p_label: String = "Muro Inti", p_axis: Vector2 = Vector2.ZERO, p_amplitude: float = 0.0, p_speed: float = 1.0) -> void:
	wall_size = p_size
	wall_label = p_label
	movement_axis = p_axis
	movement_amplitude = max(0.0, p_amplitude)
	movement_speed = max(0.1, p_speed)
	moving_enabled = movement_axis.length() > 0.0 and movement_amplitude > 0.0
	base_position = position
	queue_redraw()

func get_collision_rect() -> Rect2:
	return Rect2(position - wall_size * 0.5, wall_size)

func get_bounce_normal(old_pos: Vector2, new_pos: Vector2) -> Vector2:
	var rect: Rect2 = get_collision_rect()
	if not rect.has_point(new_pos):
		return Vector2.ZERO

	# Se estima la normal según el lado por donde ingresó el proyectil.
	if old_pos.x < rect.position.x:
		return Vector2.LEFT
	if old_pos.x > rect.position.x + rect.size.x:
		return Vector2.RIGHT
	if old_pos.y < rect.position.y:
		return Vector2.UP
	if old_pos.y > rect.position.y + rect.size.y:
		return Vector2.DOWN

	# Si el proyectil aparece dentro del muro, se toma el lado más cercano.
	var left_dist: float = abs(new_pos.x - rect.position.x)
	var right_dist: float = abs(new_pos.x - (rect.position.x + rect.size.x))
	var top_dist: float = abs(new_pos.y - rect.position.y)
	var bottom_dist: float = abs(new_pos.y - (rect.position.y + rect.size.y))
	var min_dist: float = min(min(left_dist, right_dist), min(top_dist, bottom_dist))
	if min_dist == left_dist:
		return Vector2.LEFT
	if min_dist == right_dist:
		return Vector2.RIGHT
	if min_dist == top_dist:
		return Vector2.UP
	return Vector2.DOWN

func get_push_position(pos: Vector2, normal: Vector2) -> Vector2:
	var rect: Rect2 = get_collision_rect()
	if normal == Vector2.LEFT:
		pos.x = rect.position.x - 6.0
	elif normal == Vector2.RIGHT:
		pos.x = rect.position.x + rect.size.x + 6.0
	elif normal == Vector2.UP:
		pos.y = rect.position.y - 6.0
	elif normal == Vector2.DOWN:
		pos.y = rect.position.y + rect.size.y + 6.0
	return pos

func _draw() -> void:
	var rect: Rect2 = Rect2(-wall_size * 0.5, wall_size)
	var glow_alpha: float = 0.22 + 0.12 * sin(time_passed * 5.0) if moving_enabled else 0.16
	draw_rect(rect.grow(8.0), Color(1.0, 0.72, 0.10, glow_alpha), true)
	draw_rect(rect, wall_color, true)
	draw_rect(rect, Color(1.0, 0.86, 0.28, 0.95), false, 4.0)

	# Decoración inca para que la superficie de rebote se vea como parte del nivel.
	for i in range(5):
		var y: float = rect.position.y + 20.0 + float(i) * (wall_size.y - 40.0) / 4.0
		draw_line(Vector2(rect.position.x + 5.0, y), Vector2(rect.position.x + wall_size.x - 5.0, y), Color(0.22, 0.09, 0.02, 0.55), 3.0)

	# Indicador azul de normal/reflexión.
	var normal_hint: Vector2 = Vector2.RIGHT if wall_size.y > wall_size.x else Vector2.UP
	draw_line(Vector2.ZERO, normal_hint * 34.0, Color(0.0, 0.85, 1.0, 0.85), 3.0)
	draw_circle(normal_hint * 34.0, 5.0, Color(0.0, 0.85, 1.0, 0.85))

	# Indicador visual del movimiento de la tabla.
	if moving_enabled:
		var axis: Vector2 = movement_axis.normalized()
		draw_line(-axis * (movement_amplitude + 12.0), axis * (movement_amplitude + 12.0), Color(1.0, 0.95, 0.35, 0.35), 2.0)
		draw_circle(axis * movement_amplitude, 4.0, Color(1.0, 0.95, 0.35, 0.75))
		draw_circle(-axis * movement_amplitude, 4.0, Color(1.0, 0.95, 0.35, 0.75))
