extends Node2D

signal projectile_finished(was_hit: bool, angle_deg: float, shot_type: String)

var direction: Vector2 = Vector2.RIGHT
var speed: float = 560.0
var life_time: float = 2.3
var angle_deg: float = 0.0
var shot_type: String = "simple"
var finished: bool = false
var trail: Array[Vector2] = []

func _ready() -> void:
	add_to_group("projectiles")
	queue_redraw()

func setup(angle_rad: float, projectile_speed: float, p_shot_type: String) -> void:
	direction = Vector2(cos(angle_rad), sin(angle_rad)).normalized()
	speed = projectile_speed
	angle_deg = rad_to_deg(angle_rad)
	shot_type = p_shot_type
	rotation = angle_rad

func _process(delta: float) -> void:
	if finished:
		return
	var old_pos: Vector2 = position
	trail.append(position)
	if trail.size() > 8:
		trail.pop_front()
	position += direction * speed * delta
	life_time -= delta
	_check_target_collision(old_pos)
	if life_time <= 0.0 or position.x > 3100 or position.x < -90 or position.y < -90 or position.y > 780:
		_finish(false)
	queue_redraw()

func _check_target_collision(old_pos: Vector2) -> void:
	for target in get_tree().get_nodes_in_group("targets"):
		if not is_instance_valid(target):
			continue
		if target.is_dead:
			continue
		var hit_center: Vector2 = target.call("get_hit_center") if target.has_method("get_hit_center") else target.position
		var hit_distance: float = _distance_point_to_segment(hit_center, old_pos, position)
		if hit_distance <= target.get_hit_radius():
			target.take_hit()
			_finish(true)
			return

func _distance_point_to_segment(point: Vector2, a: Vector2, b: Vector2) -> float:
	var ab: Vector2 = b - a
	var ab_len_sq: float = ab.length_squared()
	if ab_len_sq <= 0.001:
		return point.distance_to(a)
	var t: float = clamp((point - a).dot(ab) / ab_len_sq, 0.0, 1.0)
	return point.distance_to(a + ab * t)

func _finish(was_hit: bool) -> void:
	if finished:
		return
	finished = true
	projectile_finished.emit(was_hit, angle_deg, shot_type)
	queue_free()

func _draw() -> void:
	for i in range(trail.size()):
		var p: Vector2 = trail[i] - position
		var a = float(i + 1) / float(trail.size())
		draw_circle(p, 8.0 * a, Color(1.0, 0.72, 0.12, 0.16 * a))
	draw_circle(Vector2.ZERO, 9, Color(1.0, 0.86, 0.16, 0.98))
	draw_circle(Vector2.ZERO, 15, Color(1.0, 0.35, 0.08, 0.30))
	draw_line(Vector2(-18, 0), Vector2(18, 0), Color(1.0, 0.94, 0.38, 0.9), 3.0)
