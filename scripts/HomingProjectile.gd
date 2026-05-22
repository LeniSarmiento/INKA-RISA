extends Node2D

signal projectile_finished(was_hit: bool, angle_deg: float, shot_type: String)
signal homing_update(angle_deg: float, desired_angle_deg: float, turn_speed: float)

var direction: Vector2 = Vector2.RIGHT
var speed: float = 430.0
var turn_speed: float = 4.2
var life_time: float = 5.0
var finished: bool = false
var target_node: Node2D = null
var trail: Array[Vector2] = []
var current_angle_deg: float = 0.0
var desired_angle_deg: float = 0.0

func _ready() -> void:
	add_to_group("projectiles")
	add_to_group("advanced_projectiles")
	queue_redraw()

func setup(angle_rad: float, projectile_speed: float, p_turn_speed: float, p_target: Node2D = null) -> void:
	direction = Vector2(cos(angle_rad), sin(angle_rad)).normalized()
	speed = projectile_speed
	turn_speed = max(0.2, p_turn_speed)
	target_node = p_target
	rotation = angle_rad
	current_angle_deg = rad_to_deg(angle_rad)

func _process(delta: float) -> void:
	if finished:
		return
	trail.append(global_position)
	if trail.size() > 18:
		trail.pop_front()
	_update_target_reference()
	if is_instance_valid(target_node):
		var desired_direction := (target_node.global_position - global_position).normalized()
		var current_angle := direction.angle()
		var desired_angle := desired_direction.angle()
		var new_angle := lerp_angle(current_angle, desired_angle, clamp(turn_speed * delta, 0.0, 1.0))
		direction = Vector2(cos(new_angle), sin(new_angle)).normalized()
		rotation = new_angle
		current_angle_deg = rad_to_deg(new_angle)
		desired_angle_deg = rad_to_deg(desired_angle)
		homing_update.emit(current_angle_deg, desired_angle_deg, turn_speed)
	global_position += direction * speed * delta
	_check_target_collision()
	life_time -= delta
	if life_time <= 0.0 or global_position.x > 1380 or global_position.x < -120 or global_position.y < -120 or global_position.y > 820:
		_finish(false)
	queue_redraw()

func _update_target_reference() -> void:
	if is_instance_valid(target_node) and not target_node.is_dead:
		return
	var best_target: Node2D = null
	var best_distance := INF
	for target in get_tree().get_nodes_in_group("targets"):
		if not is_instance_valid(target) or target.is_dead:
			continue
		var d := global_position.distance_to(target.global_position)
		if d < best_distance:
			best_distance = d
			best_target = target
	target_node = best_target

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
	projectile_finished.emit(was_hit, current_angle_deg, "homing")
	queue_free()

func _draw() -> void:
	for i in range(trail.size()):
		var p: Vector2 = to_local(trail[i])
		var a := float(i + 1) / float(trail.size())
		draw_circle(p, 5.0 * a, Color(0.6, 1.0, 0.28, 0.16 * a))
	draw_circle(Vector2.ZERO, 9.0, Color(0.6, 1.0, 0.28, 0.95))
	draw_circle(Vector2.ZERO, 17.0, Color(0.0, 0.75, 0.95, 0.22))
	draw_line(Vector2(-20, 0), Vector2(25, 0), Color(1.0, 0.94, 0.40, 0.9), 3.0)
	if is_instance_valid(target_node):
		var local_target := to_local(target_node.global_position)
		draw_line(Vector2.ZERO, local_target.normalized() * 44.0, Color(0.6, 1.0, 0.28, 0.70), 2.0)
