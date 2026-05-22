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
	trail.append(global_position)
	if trail.size() > 8:
		trail.pop_front()
	global_position += direction * speed * delta
	life_time -= delta
	_check_target_collision()
	if life_time <= 0.0 or global_position.x > 1350 or global_position.x < -90 or global_position.y < -90 or global_position.y > 780:
		_finish(false)
	queue_redraw()

func _check_target_collision() -> void:
	for target in get_tree().get_nodes_in_group("targets"):
		if not is_instance_valid(target):
			continue
		if target.is_dead:
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
		draw_circle(p, 8.0 * a, Color(1.0, 0.72, 0.12, 0.16 * a))
	draw_circle(Vector2.ZERO, 9, Color(1.0, 0.86, 0.16, 0.98))
	draw_circle(Vector2.ZERO, 15, Color(1.0, 0.35, 0.08, 0.30))
	draw_line(Vector2(-18, 0), Vector2(18, 0), Color(1.0, 0.94, 0.38, 0.9), 3.0)
