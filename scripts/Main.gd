extends Node2D

const BACKGROUND_SCENE = preload("res://scenes/Background.tscn")
const PLAYER_SCENE = preload("res://scenes/Player.tscn")
const PROJECTILE_SCENE = preload("res://scenes/Projectile.tscn")
const TARGET_SCENE = preload("res://scenes/Target.tscn")
const RICOCHET_PROJECTILE_SCENE = preload("res://scenes/RicochetProjectile.tscn")
const HOMING_PROJECTILE_SCENE = preload("res://scenes/HomingProjectile.tscn")
const LASER_SENSOR_SCENE = preload("res://scenes/LaserSensor.tscn")
const RICOCHET_WALL_SCENE = preload("res://scenes/RicochetWall.tscn")
const GAME_HUD_SCRIPT = preload("res://scripts/GameHUD.gd")

var background: Node2D
var player: Node2D
var laser_sensor: Node2D
var hud_layer: CanvasLayer
var center_message: Label
var level_banner_timer: float = 2.0

var theta_base_rad: float = 0.0
var theta_base_deg: float = 0.0
var delta_theta_deg: float = 10.0
var projectile_count: int = 3
var projectile_speed: float = 560.0
var cooldown: float = 0.34
var cooldown_timer: float = 0.0
var max_delta_theta: float = 35.0
var max_projectiles: int = 9

var current_level: int = 1
var max_level: int = 10
var level_goal_hits: int = 6
var level_hits: int = 0
var level_attempts: int = 0
var level_misses: int = 0
var level_time: float = 0.0
var total_attempts: int = 0
var total_hits: int = 0
var total_misses: int = 0
var score: int = 0
var lives: int = 3
var spawn_timer: float = 0.0
var spawn_interval: float = 1.30
var max_alive_targets: int = 4
var target_speed: float = 45.0
var target_radius: float = 36.0
var target_hp: int = 1
var game_finished: bool = false
var game_paused: bool = false

# Parámetros EE3: interacciones avanzadas.
var max_bounces: int = 3
var ray_distance: float = 680.0
var turn_speed: float = 4.2
var ricochet_attempts: int = 0
var ricochet_hits: int = 0
var ricochet_events: int = 0
var homing_attempts: int = 0
var homing_hits: int = 0
var ray_attempts: int = 0
var ray_hits: int = 0
var last_collision_normal: Vector2 = Vector2.ZERO
var last_ray_result: String = "Sin uso"
var last_homing_info: String = "Sin uso"
var last_advanced_mechanic: String = "Pendiente de prueba"

var last_cleaning_note: String = "Parámetros válidos"
var last_runtime_csv_path: String = ""

func _make_gameplay_node_pausable(node: Node) -> void:
	# Main y el HUD quedan activos para poder quitar la pausa,
	# pero todos los objetos del juego deben detenerse cuando get_tree().paused = true.
	node.process_mode = Node.PROCESS_MODE_PAUSABLE
	for child in node.get_children():
		_make_gameplay_node_pausable(child)


func _play_player_shoot_animation() -> void:
	if is_instance_valid(player) and player.has_method("start_shoot_animation"):
		player.start_shoot_animation()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	randomize()
	background = BACKGROUND_SCENE.instantiate()
	_make_gameplay_node_pausable(background)
	add_child(background)

	player = PLAYER_SCENE.instantiate()
	_make_gameplay_node_pausable(player)
	player.position = Vector2(180, 615)
	add_child(player)

	laser_sensor = LASER_SENSOR_SCENE.instantiate()
	_make_gameplay_node_pausable(laser_sensor)
	add_child(laser_sensor)
	laser_sensor.setup(player, ray_distance)
	laser_sensor.ray_tested.connect(_on_ray_tested)

	_create_hud()
	start_level(1)

func _process(delta: float) -> void:
	if game_paused:
		return
	if game_finished:
		return
	level_time += delta
	if cooldown_timer > 0.0:
		cooldown_timer -= delta

	var direction = get_global_mouse_position() - player.global_position
	if direction.length() > 1.0:
		theta_base_rad = direction.angle()
		theta_base_deg = rad_to_deg(theta_base_rad)
		player.set_aim(theta_base_rad)

	spawn_timer -= delta
	if spawn_timer <= 0.0 and get_tree().get_nodes_in_group("targets").size() < max_alive_targets:
		spawn_one_target()
		spawn_timer = spawn_interval

	if level_banner_timer > 0.0:
		level_banner_timer -= delta
		center_message.visible = true
	else:
		center_message.visible = false

	update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if game_finished:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
			reset_all_game()
		return

	if game_paused:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_P:
				toggle_pause()
			elif event.keycode == KEY_ESCAPE:
				get_tree().paused = false
				get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			try_shoot(false)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			try_shoot(true)

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_Q:
				delta_theta_deg -= 2.0
				sanitize_pattern_params()
			KEY_E:
				delta_theta_deg += 2.0
				sanitize_pattern_params()
			KEY_Z:
				projectile_count -= 2
				sanitize_pattern_params()
			KEY_X:
				projectile_count += 2
				sanitize_pattern_params()
			KEY_A:
				try_ricochet_shot()
			KEY_S:
				try_homing_shot()
			KEY_F:
				try_laser_ray()
			KEY_R:
				reset_all_game()
			KEY_L:
				save_runtime_record()
			KEY_N:
				advance_level_for_demo()
			KEY_P:
				toggle_pause()
			KEY_ESCAPE:
				get_tree().paused = false
				get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func start_level(level: int) -> void:
	current_level = clamp(level, 1, max_level)
	level_hits = 0
	level_attempts = 0
	level_misses = 0
	level_time = 0.0
	level_banner_timer = 2.0
	game_finished = false
	_clear_playfield()
	configure_difficulty(current_level)
	setup_ricochet_arena()
	center_message.text = "NIVEL %d / 10\nEE3: rebote + rayo + guía integrados" % current_level
	for i in range(min(max_alive_targets, 2 + current_level)):
		spawn_one_target()
	update_hud()

func configure_difficulty(level: int) -> void:
	# La dificultad sube por cantidad, velocidad, tamaño y resistencia del objetivo.
	level_goal_hits = 5 + level
	max_alive_targets = clamp(3 + int(level / 2), 4, 9)
	spawn_interval = max(0.42, 1.35 - float(level) * 0.085)
	target_speed = 42.0 + float(level) * 18.0
	target_radius = max(19.0, 38.0 - float(level) * 1.7)
	target_hp = 1
	if level >= 6:
		target_hp = 2
	if level >= 9:
		target_hp = 3

	projectile_speed = 560.0 + float(level) * 18.0
	cooldown = max(0.20, 0.36 - float(level) * 0.012)
	delta_theta_deg = clamp(8.0 + float(level) * 0.8, 8.0, 18.0)
	projectile_count = 3 if level < 4 else 5
	if level >= 8:
		projectile_count = 7

	# Parámetros avanzados para EE3.
	max_bounces = clamp(2 + int(level / 4), 3, 5)
	ray_distance = clamp(620.0 + float(level) * 18.0, 620.0, 780.0)
	turn_speed = clamp(3.4 + float(level) * 0.16, 3.4, 5.2)
	if is_instance_valid(laser_sensor):
		laser_sensor.ray_distance = ray_distance
	sanitize_pattern_params()
	sanitize_advanced_params()

func setup_ricochet_arena() -> void:
	# Tres superficies con ángulos/posiciones diferentes para probar el ricochet.
	_create_wall(Vector2(680, 450), Vector2(26, 210), "Muro vertical")
	_create_wall(Vector2(920, 255), Vector2(240, 24), "Muro horizontal")
	_create_wall(Vector2(1060, 520), Vector2(28, 170), "Muro final")

func _create_wall(pos: Vector2, size: Vector2, label: String) -> void:
	var wall = RICOCHET_WALL_SCENE.instantiate()
	_make_gameplay_node_pausable(wall)
	wall.position = pos
	add_child(wall)
	wall.setup(size, label)

func advance_level_for_demo() -> void:
	if current_level < max_level:
		start_level(current_level + 1)
	else:
		finish_game()

func try_shoot(is_spread: bool) -> void:
	if cooldown_timer > 0.0:
		return
	cooldown_timer = cooldown
	_play_player_shoot_animation()
	sanitize_pattern_params()
	if is_spread:
		shoot_spread()
	else:
		shoot_projectile(theta_base_rad, "simple")
	update_hud()

func shoot_spread() -> void:
	var center_index = float(projectile_count - 1) / 2.0
	for i in range(projectile_count):
		var offset_deg = (float(i) - center_index) * delta_theta_deg
		var angle = theta_base_rad + deg_to_rad(offset_deg)
		shoot_projectile(angle, "spread")

func shoot_projectile(angle_rad: float, shot_type: String) -> void:
	total_attempts += 1
	level_attempts += 1
	var projectile = PROJECTILE_SCENE.instantiate()
	_make_gameplay_node_pausable(projectile)
	projectile.global_position = player.get_muzzle_global_position()
	add_child(projectile)
	projectile.setup(angle_rad, projectile_speed, shot_type)
	projectile.projectile_finished.connect(_on_projectile_finished)

func try_ricochet_shot() -> void:
	if cooldown_timer > 0.0:
		return
	cooldown_timer = cooldown
	_play_player_shoot_animation()
	sanitize_advanced_params()
	total_attempts += 1
	level_attempts += 1
	ricochet_attempts += 1
	last_advanced_mechanic = "Rebote: disparo con reflexión"
	var projectile = RICOCHET_PROJECTILE_SCENE.instantiate()
	_make_gameplay_node_pausable(projectile)
	projectile.global_position = player.get_muzzle_global_position()
	add_child(projectile)
	projectile.setup(theta_base_rad, projectile_speed + 40.0, max_bounces)
	projectile.projectile_finished.connect(_on_advanced_projectile_finished)
	projectile.ricochet_event.connect(_on_ricochet_event)
	update_hud()

func try_homing_shot() -> void:
	if cooldown_timer > 0.0:
		return
	cooldown_timer = cooldown
	_play_player_shoot_animation()
	sanitize_advanced_params()
	total_attempts += 1
	level_attempts += 1
	homing_attempts += 1
	last_advanced_mechanic = "Guía: seguimiento angular"
	var target = get_nearest_target(player.global_position)
	var projectile = HOMING_PROJECTILE_SCENE.instantiate()
	_make_gameplay_node_pausable(projectile)
	projectile.global_position = player.get_muzzle_global_position()
	add_child(projectile)
	projectile.setup(theta_base_rad, projectile_speed * 0.80, turn_speed, target)
	projectile.projectile_finished.connect(_on_advanced_projectile_finished)
	projectile.homing_update.connect(_on_homing_update)
	update_hud()

func try_laser_ray() -> void:
	_play_player_shoot_animation()
	sanitize_advanced_params()
	ray_attempts += 1
	last_advanced_mechanic = "Rayo del Inti: detección"
	laser_sensor.fire_pulse()
	update_hud()

func _on_projectile_finished(was_hit: bool, angle_deg: float, shot_type: String) -> void:
	if not was_hit:
		total_misses += 1
		level_misses += 1
	update_hud()

func _on_advanced_projectile_finished(was_hit: bool, angle_deg: float, shot_type: String) -> void:
	if was_hit:
		if shot_type == "ricochet":
			ricochet_hits += 1
		elif shot_type == "homing":
			homing_hits += 1
	else:
		total_misses += 1
		level_misses += 1
	update_hud()

func _on_ricochet_event(bounce_count: int, normal: Vector2, angle_after_deg: float) -> void:
	ricochet_events += 1
	last_collision_normal = normal
	last_advanced_mechanic = "Rebote %d | normal=(%.0f, %.0f) | salida=%.1f°" % [bounce_count, normal.x, normal.y, angle_after_deg]
	update_hud()

func _on_homing_update(angle_deg: float, desired_angle_deg: float, p_turn_speed: float) -> void:
	last_homing_info = "actual %.1f° → objetivo %.1f° | giro %.1f" % [angle_deg, desired_angle_deg, p_turn_speed]

func _on_ray_tested(ray_hit: bool, distance: float, target_name: String) -> void:
	if ray_hit:
		ray_hits += 1
		last_ray_result = "Detectó objetivo a %.0f px" % distance
	else:
		last_ray_result = "Sin impacto | alcance %.0f px" % ray_distance
	update_hud()

func get_nearest_target(from_pos: Vector2) -> Node2D:
	var best_target: Node2D = null
	var best_distance = INF
	for target in get_tree().get_nodes_in_group("targets"):
		if not is_instance_valid(target) or target.is_dead:
			continue
		var d = from_pos.distance_to(target.global_position)
		if d < best_distance:
			best_distance = d
			best_target = target
	return best_target

func spawn_one_target() -> void:
	var target = TARGET_SCENE.instantiate()
	_make_gameplay_node_pausable(target)
	var y_min = 150.0
	var y_max = 585.0
	var pos = Vector2(randf_range(980.0, 1320.0), randf_range(y_min, y_max))
	target.position = pos
	add_child(target)
	target.setup(current_level, target_speed * randf_range(0.85, 1.18), target_radius, target_hp)
	target.destroyed.connect(_on_target_destroyed)
	target.escaped.connect(_on_target_escaped)

func _on_target_destroyed(points: int) -> void:
	total_hits += 1
	level_hits += 1
	score += points * 10
	if level_hits >= level_goal_hits:
		if current_level >= max_level:
			finish_game()
		else:
			start_level(current_level + 1)
	else:
		update_hud()

func _on_target_escaped() -> void:
	lives -= 1
	total_misses += 1
	level_misses += 1
	player.pulse_damage()
	if lives <= 0:
		reset_all_game()
		center_message.text = "Perdiste las 3 vidas\nReinicio al nivel 1"
		level_banner_timer = 2.5
		update_hud()
		return
	update_hud()

func sanitize_pattern_params() -> void:
	last_cleaning_note = "Parámetros válidos"
	if is_nan(delta_theta_deg):
		delta_theta_deg = 10.0
		last_cleaning_note = "Dato faltante: Δθ reemplazado por 10°"
	elif delta_theta_deg < 0.0:
		delta_theta_deg = 0.0
		last_cleaning_note = "Dato atípico: Δθ negativo corregido a 0°"
	elif delta_theta_deg > max_delta_theta:
		delta_theta_deg = max_delta_theta
		last_cleaning_note = "Dato atípico: Δθ alto corregido a 35°"

	var original_count = projectile_count
	projectile_count = clamp(projectile_count, 1, max_projectiles)
	if projectile_count % 2 == 0:
		projectile_count += 1
		if projectile_count > max_projectiles:
			projectile_count -= 2
	if projectile_count != original_count:
		last_cleaning_note += " | Proyectiles ajustados a número impar entre 1 y 9"

func sanitize_advanced_params() -> void:
	if max_bounces < 1:
		max_bounces = 1
		last_cleaning_note = "Rebotes negativos/faltantes corregidos a 1"
	elif max_bounces > 5:
		max_bounces = 5
		last_cleaning_note = "Rebotes atípicos corregidos al máximo 5"
	if ray_distance < 120.0:
		ray_distance = 120.0
		last_cleaning_note = "Alcance del rayo bajo corregido a 120 px"
	elif ray_distance > 900.0:
		ray_distance = 900.0
		last_cleaning_note = "Alcance del rayo alto corregido a 900 px"
	if turn_speed < 0.2:
		turn_speed = 0.2
		last_cleaning_note = "Giro faltante/negativo corregido a 0.2"
	elif turn_speed > 7.0:
		turn_speed = 7.0
		last_cleaning_note = "Giro atípico corregido a 7.0"

func toggle_pause() -> void:
	game_paused = not game_paused
	get_tree().paused = game_paused
	center_message.visible = game_paused
	if game_paused:
		center_message.text = "PAUSA\nPresiona P o el botón de pausa para continuar"
	else:
		center_message.visible = false
	update_hud()

func reset_all_game() -> void:
	total_attempts = 0
	total_hits = 0
	total_misses = 0
	ricochet_attempts = 0
	ricochet_hits = 0
	ricochet_events = 0
	homing_attempts = 0
	homing_hits = 0
	ray_attempts = 0
	ray_hits = 0
	score = 0
	lives = 3
	game_paused = false
	get_tree().paused = false
	last_cleaning_note = "Juego reiniciado"
	last_runtime_csv_path = ""
	last_ray_result = "Sin uso"
	last_homing_info = "Sin uso"
	last_advanced_mechanic = "Pendiente de prueba"
	start_level(1)

func finish_game() -> void:
	game_finished = true
	_clear_playfield()
	center_message.visible = true
	center_message.text = "¡GANASTE INKARISE EE3!\nCompletaste los 10 niveles\nPrecisión total: %.1f%%\nPresiona R para reiniciar" % get_total_precision()
	update_hud()

func _clear_playfield() -> void:
	for projectile in get_tree().get_nodes_in_group("projectiles"):
		projectile.queue_free()
	for target in get_tree().get_nodes_in_group("targets"):
		target.queue_free()
	for wall in get_tree().get_nodes_in_group("ricochet_walls"):
		wall.queue_free()

func get_total_precision() -> float:
	if total_attempts <= 0:
		return 0.0
	return float(total_hits) * 100.0 / float(total_attempts)

func get_level_precision() -> float:
	if level_attempts <= 0:
		return 0.0
	return float(level_hits) * 100.0 / float(level_attempts)

func get_advanced_hit_rate() -> float:
	var attempts = ricochet_attempts + homing_attempts + ray_attempts
	var hits = ricochet_hits + homing_hits + ray_hits
	if attempts <= 0:
		return 0.0
	return float(hits) * 100.0 / float(attempts)

func save_runtime_record() -> void:
	var path = "user://inka_rise_ee3_registro_runtime.csv"
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		last_cleaning_note = "No se pudo guardar el registro runtime"
		return
	file.store_line("nivel,theta_base_deg,delta_theta_deg,proyectiles,velocidad,recarga,rebotes_max,distancia_rayo,giro_guia,intentos_nivel,impactos_nivel,fallos_nivel,precision_nivel,rebote_intentos,rebote_hits,rebotes,ray_intentos,ray_hits,guia_intentos,guia_hits,acierto_avanzado,nota_limpieza")
	file.store_line("%d,%.2f,%.2f,%d,%.2f,%.2f,%d,%.2f,%.2f,%d,%d,%d,%.2f,%d,%d,%d,%d,%d,%d,%d,%.2f,%s" % [current_level, theta_base_deg, delta_theta_deg, projectile_count, projectile_speed, cooldown, max_bounces, ray_distance, turn_speed, level_attempts, level_hits, level_misses, get_level_precision(), ricochet_attempts, ricochet_hits, ricochet_events, ray_attempts, ray_hits, homing_attempts, homing_hits, get_advanced_hit_rate(), last_cleaning_note])
	file.close()
	last_runtime_csv_path = ProjectSettings.globalize_path(path)
	last_cleaning_note = "Registro EE3 guardado en user://inka_rise_ee3_registro_runtime.csv"

func _create_hud() -> void:
	hud_layer = GAME_HUD_SCRIPT.new()
	add_child(hud_layer)
	if hud_layer.has_signal("pause_requested"):
		hud_layer.pause_requested.connect(toggle_pause)
	center_message = hud_layer.center_message

func update_hud() -> void:
	var cooldown_state: String = "LISTO" if cooldown_timer <= 0.0 else "RECARGANDO"
	if hud_layer != null and hud_layer.has_method("update_data"):
		hud_layer.update_data({
			"current_level": current_level,
			"max_level": max_level,
			"lives": lives,
			"score": score,
			"level_hits": level_hits,
			"level_goal_hits": level_goal_hits,
			"theta_base_deg": theta_base_deg,
			"cooldown_state": cooldown_state,
			"delta_theta_deg": delta_theta_deg,
			"projectile_count": projectile_count,
			"projectile_speed": projectile_speed,
			"cooldown": cooldown,
			"max_bounces": max_bounces,
			"normal_x": last_collision_normal.x,
			"normal_y": last_collision_normal.y,
			"ray_distance": ray_distance,
			"turn_speed": turn_speed,
			"ricochet_attempts": ricochet_attempts,
			"ricochet_hits": ricochet_hits,
			"ricochet_events": ricochet_events,
			"ray_attempts": ray_attempts,
			"ray_hits": ray_hits,
			"homing_attempts": homing_attempts,
			"homing_hits": homing_hits,
			"level_attempts": level_attempts,
			"level_misses": level_misses,
			"level_precision": get_level_precision(),
			"advanced_hit_rate": get_advanced_hit_rate(),
			"last_ray_result": last_ray_result,
			"last_homing_info": last_homing_info,
			"last_advanced_mechanic": last_advanced_mechanic,
			"last_cleaning_note": last_cleaning_note,
			"is_paused": game_paused
		})
