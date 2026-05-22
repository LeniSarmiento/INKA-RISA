extends Node2D

var wall_size: Vector2 = Vector2(28, 180)
var wall_label: String = "Muro Inti"
var wall_color: Color = Color(0.72, 0.45, 0.18, 0.84)

func _ready() -> void:
	add_to_group("ricochet_walls")
	queue_redraw()

func setup(p_size: Vector2, p_label: String = "Muro Inti") -> void:
	wall_size = p_size
	wall_label = p_label
	queue_redraw()

func get_collision_rect() -> Rect2:
	return Rect2(global_position - wall_size * 0.5, wall_size)

func get_bounce_normal(old_pos: Vector2, new_pos: Vector2) -> Vector2:
	var rect = get_collision_rect()
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
	var left_dist = abs(new_pos.x - rect.position.x)
	var right_dist = abs(new_pos.x - (rect.position.x + rect.size.x))
	var top_dist = abs(new_pos.y - rect.position.y)
	var bottom_dist = abs(new_pos.y - (rect.position.y + rect.size.y))
	var min_dist = min(min(left_dist, right_dist), min(top_dist, bottom_dist))
	if min_dist == left_dist:
		return Vector2.LEFT
	if min_dist == right_dist:
		return Vector2.RIGHT
	if min_dist == top_dist:
		return Vector2.UP
	return Vector2.DOWN

func get_push_position(pos: Vector2, normal: Vector2) -> Vector2:
	var rect = get_collision_rect()
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
	var rect = Rect2(-wall_size * 0.5, wall_size)
	draw_rect(rect, wall_color, true)
	draw_rect(rect, Color(1.0, 0.86, 0.28, 0.95), false, 4.0)
	# Decoración inca para que la superficie de rebote se vea como parte del nivel.
	for i in range(5):
		var y = rect.position.y + 20.0 + float(i) * (wall_size.y - 40.0) / 4.0
		draw_line(Vector2(rect.position.x + 5.0, y), Vector2(rect.position.x + wall_size.x - 5.0, y), Color(0.22, 0.09, 0.02, 0.55), 3.0)
	var normal_hint = Vector2.RIGHT if wall_size.y > wall_size.x else Vector2.UP
	draw_line(Vector2.ZERO, normal_hint * 34.0, Color(0.0, 0.85, 1.0, 0.85), 3.0)
	draw_circle(normal_hint * 34.0, 5.0, Color(0.0, 0.85, 1.0, 0.85))
