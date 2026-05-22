extends Node2D

signal ray_tested(ray_hit: bool, distance: float, target_name: String)

var source_player: Node2D = null
var ray_distance: float = 680.0
var active_timer: float = 0.0
var last_hit: bool = false
var last_hit_distance: float = 0.0
var last_hit_point: Vector2 = Vector2.ZERO
var last_hit_name: String = "Sin detección"
var last_direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	add_to_group("raycast_sensors")
	queue_redraw()

func setup(p_player: Node2D, p_distance: float) -> void:
	source_player = p_player
	ray_distance = max(120.0, p_distance)

func fire_pulse() -> void:
	active_timer = 0.32
	_scan_targets(true)

func _process(delta: float) -> void:
	if active_timer > 0.0:
		active_timer -= delta
		_scan_targets(false)
	queue_redraw()

func _scan_targets(apply_damage: bool) -> void:
	if not is_instance_valid(source_player):
		return
	global_position = source_player.get_muzzle_global_position()
	last_direction = Vector2(cos(source_player.aim_angle), sin(source_player.aim_angle)).normalized()
	last_hit = false
	last_hit_distance = ray_distance
	last_hit_point = global_position + last_direction * ray_distance
	last_hit_name = "Sin detección"
	var best_target: Node2D = null
	var best_distance := ray_distance + 1.0
	for target in get_tree().get_nodes_in_group("targets"):
		if not is_instance_valid(target) or target.is_dead:
			continue
		var ray_end := global_position + last_direction * ray_distance
		var d_to_line := _distance_point_to_segment(target.global_position, global_position, ray_end)
		var projected_distance := (target.global_position - global_position).dot(last_direction)
		if projected_distance >= 0.0 and projected_distance <= ray_distance and d_to_line <= target.get_hit_radius():
			if projected_distance < best_distance:
				best_distance = projected_distance
				best_target = target
	if is_instance_valid(best_target):
		last_hit = true
		last_hit_distance = best_distance
		last_hit_point = global_position + last_direction * best_distance
		last_hit_name = best_target.name
		if apply_damage:
			best_target.take_hit()
	if apply_damage:
		ray_tested.emit(last_hit, last_hit_distance, last_hit_name)

func _distance_point_to_segment(point: Vector2, segment_a: Vector2, segment_b: Vector2) -> float:
	var ab := segment_b - segment_a
	var ab_len_sq := max(ab.length_squared(), 0.001)
	var t := clamp((point - segment_a).dot(ab) / ab_len_sq, 0.0, 1.0)
	var projection := segment_a + ab * t
	return point.distance_to(projection)

func _draw() -> void:
	if not is_instance_valid(source_player):
		return
	var end_point := to_local(last_hit_point if last_hit else global_position + last_direction * ray_distance)
	var color := Color(1.0, 0.15, 0.05, 0.92) if last_hit else Color(0.0, 0.9, 1.0, 0.50)
	var width := 7.0 if active_timer > 0.0 else 2.0
	draw_line(Vector2.ZERO, end_point, color, width)
	draw_circle(Vector2.ZERO, 8.0, Color(1.0, 0.9, 0.22, 0.90))
	if last_hit:
		draw_circle(end_point, 18.0, Color(1.0, 0.15, 0.05, 0.45))
		draw_circle(end_point, 8.0, Color(1.0, 0.86, 0.16, 0.95))
