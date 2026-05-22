extends Node2D

signal projectile_finished(was_hit: bool, angle_deg: float, shot_type: String)
signal ricochet_event(bounce_count: int, normal: Vector2, angle_after_deg: float)

var direction: Vector2 = Vector2.RIGHT
var speed: float = 620.0
var life_time: float = 4.5
var angle_deg: float = 0.0
var shot_type: String = "ricochet"
var finished: bool = false
var trail: Array[Vector2] = []
var bounce_count: int = 0
var max_bounces: int = 3
var last_normal: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("projectiles")
	add_to_group("advanced_projectiles")
	queue_redraw()

func setup(angle_rad: float, projectile_speed: float, p_max_bounces: int = 3) -> void:
	direction = Vector2(cos(angle_rad), sin(angle_rad)).normalized()
	speed = projectile_speed
	max_bounces = max(1, p_max_bounces)
	angle_deg = rad_to_deg(angle_rad)
	rotation = angle_rad

func _process(delta: float) -> void:
	if finished:
		return
	var old_pos := global_position
	trail.append(global_position)
	if trail.size() > 15:
		trail.pop_front()
	global_position += direction * speed * delta
	_check_wall_collision(old_pos)
	_check_target_collision()
	life_time -= delta
	if life_time <= 0.0 or global_position.x > 1360 or global_position.x < -120 or global_position.y < -120 or global_position.y > 820:
		_finish(false)
	queue_redraw()

func _check_wall_collision(old_pos: Vector2) -> void:
	for wall in get_tree().get_nodes_in_group("ricochet_walls"):
		if not is_instance_valid(wall):
			continue
		var normal: Vector2 = wall.get_bounce_normal(old_pos, global_position)
		if normal != Vector2.ZERO:
			bounce_count += 1
			last_normal = normal
			direction = direction.bounce(normal).normalized()
			rotation = direction.angle()
			angle_deg = rad_to_deg(rotation)
			global_position = wall.get_push_position(global_position, normal)
			ricochet_event.emit(bounce_count, normal, angle_deg)
			if bounce_count >= max_bounces:
				life_time = min(life_time, 1.0)
			return

func _check_target_collision() -> void:
	for target in get_tree().get_nodes_in_group("targets"):
		if not is_instance_valid(target) or target.is_dead:
			continue
		if global_position.distance_to(target.global_position) <= target.get_hit_radius():
			target.take_hit()
			_finish(true)
			return

func _finish(was_hit: bool) -> void:
	if finished:
		return
	finished = true
	projectile_finished.emit(was_hit, angle_deg, shot_type)
	queue_free()

func _draw() -> void:
	for i in range(trail.size()):
		var p: Vector2 = to_local(trail[i])
		var a := float(i + 1) / float(trail.size())
		draw_circle(p, 6.0 * a, Color(0.0, 0.88, 1.0, 0.18 * a))
	draw_circle(Vector2.ZERO, 10.0, Color(0.0, 0.88, 1.0, 0.95))
	draw_circle(Vector2.ZERO, 18.0, Color(1.0, 0.9, 0.18, 0.28))
	draw_line(Vector2(-22, 0), Vector2(22, 0), Color(1.0, 0.95, 0.28, 0.92), 3.0)
	if last_normal != Vector2.ZERO:
		draw_line(Vector2.ZERO, last_normal * 34.0, Color(0.0, 1.0, 1.0, 0.82), 2.5)
