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
const LEVEL_MAP_SCENE_PATH: String = "res://scenes/LevelMap.tscn"
const PLAYER_SPAWN_POSITION: Vector2 = Vector2(80, 650)
const WORLD_WIDTH: float = 3000.0
const SPREAD_SHOT_COOLDOWN: float = 5.0
const SPREAD_SHOT_COUNT: int = 3

var background: Node2D
var world_root: Node2D
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
var boss_active: bool = false
var boss_defeated: bool = false
var damage_grace_timer: float = 0.0
var camera_offset: float = 0.0
var has_ricochet_power: bool = false
var has_ray_power: bool = false
var has_homing_power: bool = false
var power_unlock_stage: int = 0
var boss_attack_timer: float = 0.0
var boss_rays: Array[Dictionary] = []
var game_over_return_timer: float = 0.0

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
var spread_cooldown_timer: float = 0.0
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

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	randomize()
	background = BACKGROUND_SCENE.instantiate()
	_make_gameplay_node_pausable(background)
	add_child(background)

	world_root = Node2D.new()
	_make_gameplay_node_pausable(world_root)
	add_child(world_root)

	player = PLAYER_SCENE.instantiate()
	_make_gameplay_node_pausable(player)
	player.position = PLAYER_SPAWN_POSITION
	world_root.add_child(player)
	if player.has_method("set_platforms"):
		player.call("set_platforms", _get_platform_rects())
	if player.has_method("set_world_width"):
		player.call("set_world_width", WORLD_WIDTH)

	laser_sensor = LASER_SENSOR_SCENE.instantiate()
	_make_gameplay_node_pausable(laser_sensor)
	world_root.add_child(laser_sensor)
	laser_sensor.setup(player, ray_distance)
	laser_sensor.ray_tested.connect(_on_ray_tested)

	_create_hud()
	var initial_level: int = 1
	var state: Node = get_node_or_null("/root/GameState")
	if is_instance_valid(state):
		initial_level = int(state.get("selected_level"))
	start_level(initial_level)

func _process(delta: float) -> void:
	if game_paused:
		return
	if game_finished:
		if game_over_return_timer > 0.0:
			game_over_return_timer -= delta
			if game_over_return_timer <= 0.0:
				_return_to_level_map_after_game_over()
		return
	level_time += delta
	if damage_grace_timer > 0.0:
		damage_grace_timer -= delta
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	if spread_cooldown_timer > 0.0:
		spread_cooldown_timer -= delta

	_sync_player_aim_with_mouse()
	_update_side_camera()
	_check_platform_collisions()
	_update_boss_attacks(delta)
	_check_goal_reached()

	spawn_timer -= delta
	if spawn_timer <= 0.0 and not boss_active and not boss_defeated and get_tree().get_nodes_in_group("targets").size() < max_alive_targets:
		spawn_one_target()
		spawn_timer = spawn_interval

	if level_banner_timer > 0.0:
		level_banner_timer -= delta
		center_message.visible = true
	else:
		center_message.visible = false

	update_hud()


func _sync_player_aim_with_mouse() -> void:
	if not is_instance_valid(player):
		return
	var mouse_global: Vector2 = get_global_mouse_position() + Vector2(camera_offset, 0.0)
	if player.has_method("set_aim_target"):
		player.call("set_aim_target", mouse_global)
		theta_base_rad = float(player.call("get_aim_angle_rad"))
	else:
		var direction: Vector2 = mouse_global - player.position
		if direction.length() > 1.0 and player.has_method("set_aim"):
			theta_base_rad = direction.angle()
			player.call("set_aim", theta_base_rad)
	theta_base_deg = rad_to_deg(theta_base_rad)

func _update_side_camera() -> void:
	if not is_instance_valid(player) or not is_instance_valid(world_root):
		return
	var target_offset: float = clamp(player.position.x - 360.0, 0.0, WORLD_WIDTH - get_viewport_rect().size.x)
	camera_offset = lerpf(camera_offset, target_offset, 0.12)
	world_root.position.x = -camera_offset
	if is_instance_valid(background) and background.has_method("set_camera_offset"):
		background.call("set_camera_offset", camera_offset)

func _unhandled_input(event: InputEvent) -> void:
	if game_finished:
		if game_over_return_timer > 0.0:
			return
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
				try_ricochet_shot()
			KEY_E:
				try_laser_ray()
			KEY_R:
				try_homing_shot()
			KEY_Z:
				projectile_count -= 2
				sanitize_pattern_params()
			KEY_X:
				projectile_count += 2
				sanitize_pattern_params()
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
	if is_instance_valid(background) and background.has_method("setup_level"):
		background.call("setup_level", current_level)
	level_hits = 0
	level_attempts = 0
	level_misses = 0
	level_time = 0.0
	level_banner_timer = 2.0
	game_finished = false
	boss_active = false
	boss_defeated = false
	damage_grace_timer = 0.0
	boss_attack_timer = 0.0
	boss_rays.clear()
	_clear_playfield()
	if is_instance_valid(player) and player.has_method("reset_to_spawn"):
		player.call("reset_to_spawn", PLAYER_SPAWN_POSITION)
	camera_offset = 0.0
	if is_instance_valid(world_root):
		world_root.position.x = 0.0
	if is_instance_valid(background) and background.has_method("set_camera_offset"):
		background.call("set_camera_offset", camera_offset)
	configure_difficulty(current_level)
	setup_ricochet_arena()
	center_message.text = "NIVEL %d / 10\nAvanza a la derecha, salta plataformas y derrota enemigos" % current_level
	for i in range(min(max_alive_targets, 3 + current_level)):
		spawn_one_target()
	update_hud()

func configure_difficulty(level: int) -> void:
	# La dificultad sube por cantidad, velocidad, tamaño y resistencia del objetivo.
	level_goal_hits = clamp(3 + int(level / 2), 4, 7)
	max_alive_targets = clamp(4 + int(level / 3), 4, 7)
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
	projectile_count = 1
	if _has_spread_reward():
		projectile_count = SPREAD_SHOT_COUNT

	# Parámetros avanzados para EE3.
	max_bounces = clamp(2 + int(level / 4), 3, 5)
	ray_distance = clamp(620.0 + float(level) * 18.0, 620.0, 780.0)
	turn_speed = clamp(3.4 + float(level) * 0.16, 3.4, 5.2)
	if is_instance_valid(laser_sensor):
		laser_sensor.ray_distance = ray_distance
	sanitize_pattern_params()
	sanitize_advanced_params()

func setup_ricochet_arena() -> void:
	_create_wall(Vector2(560, 500), Vector2(26, 120), "REBOTE 1", Vector2(0, 1), 24.0, 1.10)
	_create_wall(Vector2(930, 390), Vector2(180, 22), "REBOTE 2", Vector2(1, 0), 36.0, 1.00)
	_create_wall(Vector2(1375, 555), Vector2(26, 120), "REBOTE 3", Vector2(0, 1), 28.0, 1.20)
	_create_wall(Vector2(1765, 360), Vector2(170, 22), "REBOTE 4", Vector2(1, 0), 42.0, 1.05)
	_create_wall(Vector2(2245, 510), Vector2(26, 150), "REBOTE 5", Vector2(0, 1), 32.0, 1.30)
	_create_wall(Vector2(2650, 430), Vector2(190, 22), "REBOTE FINAL", Vector2(1, 0), 35.0, 1.15)

func _create_wall(pos: Vector2, size: Vector2, label: String, axis: Vector2 = Vector2.ZERO, amplitude: float = 0.0, speed: float = 1.0) -> void:
	var wall = RICOCHET_WALL_SCENE.instantiate()
	_make_gameplay_node_pausable(wall)
	wall.position = pos
	world_root.add_child(wall)
	wall.setup(size, label, axis, amplitude, speed)

func advance_level_for_demo() -> void:
	if current_level < max_level:
		start_level(current_level + 1)
	else:
		finish_game()

func _play_player_attack_animation() -> void:
	if is_instance_valid(player) and player.has_method("play_attack"):
		player.play_attack()

func try_shoot(is_spread: bool) -> void:
	_sync_player_aim_with_mouse()
	_play_player_attack_animation()
	sanitize_pattern_params()
	if is_spread:
		if not _has_spread_reward():
			last_advanced_mechanic = "Disparo triple bloqueado hasta el nivel 3"
			shoot_projectile(theta_base_rad, "simple")
		elif spread_cooldown_timer > 0.0:
			last_advanced_mechanic = "Triple disparo recargando"
		else:
			spread_cooldown_timer = SPREAD_SHOT_COOLDOWN
			shoot_spread()
	else:
		shoot_projectile(theta_base_rad, "simple")
	update_hud()

func _has_spread_reward() -> bool:
	if current_level >= 3:
		return true
	var state: Node = get_node_or_null("/root/GameState")
	if is_instance_valid(state):
		return int(state.get("max_unlocked_level")) >= 3
	return false

func shoot_spread() -> void:
	var center_index = float(SPREAD_SHOT_COUNT - 1) / 2.0
	for i in range(SPREAD_SHOT_COUNT):
		var offset_deg = (float(i) - center_index) * delta_theta_deg
		var angle = theta_base_rad + deg_to_rad(offset_deg)
		shoot_projectile(angle, "spread")

func shoot_projectile(angle_rad: float, shot_type: String) -> void:
	total_attempts += 1
	level_attempts += 1
	var projectile = PROJECTILE_SCENE.instantiate()
	_make_gameplay_node_pausable(projectile)
	world_root.add_child(projectile)
	projectile.position = player.get_muzzle_global_position()
	projectile.setup(angle_rad, projectile_speed, shot_type)
	projectile.projectile_finished.connect(_on_projectile_finished)

func try_ricochet_shot() -> void:
	if not has_ricochet_power:
		_show_power_locked("Derrota al boss para obtener Q REBOTE")
		return
	_sync_player_aim_with_mouse()
	if cooldown_timer > 0.0:
		return
	cooldown_timer = cooldown
	_play_player_attack_animation()
	sanitize_advanced_params()
	total_attempts += 1
	level_attempts += 1
	ricochet_attempts += 1
	last_advanced_mechanic = "Rebote: disparo con reflexión"
	var projectile = RICOCHET_PROJECTILE_SCENE.instantiate()
	_make_gameplay_node_pausable(projectile)
	world_root.add_child(projectile)
	projectile.position = player.get_muzzle_global_position()
	projectile.setup(theta_base_rad, projectile_speed + 40.0, max_bounces)
	projectile.projectile_finished.connect(_on_advanced_projectile_finished)
	projectile.ricochet_event.connect(_on_ricochet_event)
	update_hud()

func try_homing_shot() -> void:
	if not has_homing_power:
		_show_power_locked("Obtén primero REBOTE y RAYO\nLuego desbloqueas R GUÍA")
		return
	_sync_player_aim_with_mouse()
	if cooldown_timer > 0.0:
		return
	cooldown_timer = cooldown
	_play_player_attack_animation()
	sanitize_advanced_params()
	total_attempts += 1
	level_attempts += 1
	homing_attempts += 1
	last_advanced_mechanic = "Guía: seguimiento angular"
	var target = get_nearest_target(player.position)
	var projectile = HOMING_PROJECTILE_SCENE.instantiate()
	_make_gameplay_node_pausable(projectile)
	world_root.add_child(projectile)
	projectile.position = player.get_muzzle_global_position()
	projectile.setup(theta_base_rad, projectile_speed * 0.80, turn_speed, target)
	projectile.projectile_finished.connect(_on_advanced_projectile_finished)
	projectile.homing_update.connect(_on_homing_update)
	update_hud()

func try_laser_ray() -> void:
	if not has_ray_power:
		_show_power_locked("Obtén primero Q REBOTE\nDespués desbloqueas E RAYO")
		return
	_sync_player_aim_with_mouse()
	_play_player_attack_animation()
	sanitize_advanced_params()
	ray_attempts += 1
	last_advanced_mechanic = "Rayo del Inti: detección"
	laser_sensor.fire_pulse()
	update_hud()

func _show_power_locked(message: String) -> void:
	center_message.visible = true
	center_message.text = message
	level_banner_timer = 1.35
	last_advanced_mechanic = "Poder bloqueado"
	update_hud()

func _grant_next_boss_power_reward() -> void:
	if current_level >= 1 and not has_ricochet_power:
		has_ricochet_power = true
		power_unlock_stage = max(power_unlock_stage, 1)
		center_message.text = "BOSS DERROTADO\nPODER OBTENIDO: Q REBOTE"
		last_advanced_mechanic = "Boss nivel %d: desbloqueó Rebote" % current_level
	elif current_level >= 4 and not has_ray_power:
		has_ray_power = true
		power_unlock_stage = max(power_unlock_stage, 2)
		center_message.text = "BOSS DERROTADO\nPODER OBTENIDO: E RAYO"
		last_advanced_mechanic = "Boss nivel %d: desbloqueó Rayo" % current_level
	elif current_level >= 8 and not has_homing_power:
		has_homing_power = true
		power_unlock_stage = max(power_unlock_stage, 3)
		center_message.text = "BOSS DERROTADO\nPODER OBTENIDO: R GUÍA"
		last_advanced_mechanic = "Boss nivel %d: desbloqueó Guía" % current_level
	else:
		center_message.text = "BOSS DERROTADO\nCorre hasta la META"
	center_message.visible = true
	level_banner_timer = 2.0
	update_hud()

func _lose_all_powers() -> void:
	has_ricochet_power = false
	has_ray_power = false
	has_homing_power = false
	power_unlock_stage = 0

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
		var d = from_pos.distance_to(target.position)
		if d < best_distance:
			best_distance = d
			best_target = target
	return best_target

func spawn_one_target() -> void:
	var target = TARGET_SCENE.instantiate()
	_make_gameplay_node_pausable(target)
	var use_walker: bool = randf() < 0.72
	if use_walker:
		var patrols: Array[Rect2] = _get_enemy_patrols()
		var available: Array[Rect2] = []
		for candidate in patrols:
			if candidate.position.x > camera_offset + 220.0 and candidate.position.x < camera_offset + 1500.0:
				available.append(candidate)
		if available.is_empty():
			available = patrols
		var patrol: Rect2 = available[randi() % available.size()]
		target.position = Vector2(patrol.position.x, patrol.position.y)
		world_root.add_child(target)
		target.setup_walker(current_level, patrol.position.x, patrol.position.x + patrol.size.x, patrol.position.y)
	else:
		var pos = Vector2(randf_range(camera_offset + 900.0, min(WORLD_WIDTH - 220.0, camera_offset + 1500.0)), randf_range(360.0, 560.0))
		target.position = pos
		world_root.add_child(target)
		target.setup(current_level, target_speed * randf_range(0.65, 0.90), max(16.0, target_radius * 0.58), target_hp)
	target.destroyed.connect(_on_target_destroyed)
	target.escaped.connect(_on_target_escaped)

func _on_target_destroyed(points: int) -> void:
	total_hits += 1
	level_hits += 1
	score += points * 10
	if level_hits >= level_goal_hits and not boss_active and not boss_defeated:
		_spawn_boss()
		update_hud()
		return
	if boss_active and level_hits >= level_goal_hits + 1:
		boss_active = false
		boss_defeated = true
		boss_rays.clear()
		_grant_next_boss_power_reward()
		return
	if false:
		var state: Node = get_node_or_null("/root/GameState")
		if is_instance_valid(state) and state.has_method("mark_completed"):
			state.call("mark_completed", current_level, score)
		if current_level >= max_level:
			finish_game()
		else:
			start_level(current_level + 1)
	else:
		update_hud()

func _on_target_escaped() -> void:
	if boss_active:
		return
	total_misses += 1
	level_misses += 1
	_player_lose_life("Un enemigo escapó")

func _spawn_boss() -> void:
	boss_active = true
	boss_rays.clear()
	boss_attack_timer = max(0.75, 2.3 - float(current_level) * 0.10)
	for target in get_tree().get_nodes_in_group("targets"):
		if is_instance_valid(target):
			target.queue_free()
	center_message.visible = true
	center_message.text = "BOSS DEL SOL\nAtaca y esquiva para abrir la META"
	level_banner_timer = 2.0
	var boss = TARGET_SCENE.instantiate()
	_make_gameplay_node_pausable(boss)
	boss.position = Vector2(2760, 470)
	world_root.add_child(boss)
	boss.setup_boss(current_level)
	boss.destroyed.connect(_on_target_destroyed)

func _update_boss_attacks(delta: float) -> void:
	if not boss_active or boss_defeated:
		boss_rays.clear()
		queue_redraw()
		return
	var boss: Node2D = _get_active_boss()
	if not is_instance_valid(boss):
		return
	boss_attack_timer -= delta
	if boss_attack_timer <= 0.0:
		_fire_boss_radial_rays(boss)
		boss_attack_timer = max(0.75, 2.35 - float(current_level) * 0.12)

	var body: Rect2 = player.call("get_body_rect") if is_instance_valid(player) and player.has_method("get_body_rect") else Rect2(player.position + Vector2(-14, -48), Vector2(28, 48))
	var body_center: Vector2 = body.get_center()
	for i in range(boss_rays.size() - 1, -1, -1):
		boss_rays[i]["time"] = float(boss_rays[i]["time"]) - delta
		if float(boss_rays[i]["time"]) <= 0.0:
			boss_rays.remove_at(i)
			continue
		var origin: Vector2 = boss_rays[i]["origin"]
		var direction: Vector2 = boss_rays[i]["direction"]
		var length: float = float(boss_rays[i]["length"])
		if damage_grace_timer <= 0.0 and _distance_point_to_segment(body_center, origin, origin + direction * length) <= 16.0:
			_player_take_damage()
			break
	queue_redraw()

func _get_active_boss() -> Node2D:
	for target in get_tree().get_nodes_in_group("targets"):
		if is_instance_valid(target) and bool(target.get("is_boss")):
			return target
	return null

func _fire_boss_radial_rays(boss: Node2D) -> void:
	var ray_count: int = clamp(4 + current_level, 5, 14)
	var ray_length: float = 230.0 + float(current_level) * 24.0
	var phase: float = randf_range(0.0, TAU)
	for i in range(ray_count):
		var angle: float = phase + TAU * float(i) / float(ray_count)
		boss_rays.append({
			"origin": boss.position,
			"direction": Vector2(cos(angle), sin(angle)).normalized(),
			"length": ray_length,
			"time": 0.70 + float(current_level) * 0.02
		})
	last_advanced_mechanic = "Boss: rayos radiales nivel %d" % current_level

func _distance_point_to_segment(point: Vector2, a: Vector2, b: Vector2) -> float:
	var ab: Vector2 = b - a
	var ab_len_sq: float = ab.length_squared()
	if ab_len_sq <= 0.001:
		return point.distance_to(a)
	var t: float = clamp((point - a).dot(ab) / ab_len_sq, 0.0, 1.0)
	return point.distance_to(a + ab * t)

func _draw() -> void:
	for ray in boss_rays:
		var origin: Vector2 = ray["origin"] - Vector2(camera_offset, 0.0)
		var direction: Vector2 = ray["direction"]
		var length: float = float(ray["length"])
		var alpha: float = clamp(float(ray["time"]) / 0.8, 0.25, 0.95)
		draw_line(origin, origin + direction * length, Color(1.0, 0.18, 0.04, alpha), 5.0)
		draw_line(origin, origin + direction * length, Color(1.0, 0.88, 0.18, alpha), 2.0)

func _check_platform_collisions() -> void:
	if damage_grace_timer > 0.0 or not is_instance_valid(player):
		return
	var body: Rect2 = player.call("get_body_rect") if player.has_method("get_body_rect") else Rect2(player.position + Vector2(-20, -60), Vector2(40, 60))
	for target in get_tree().get_nodes_in_group("targets"):
		if not is_instance_valid(target) or target.is_dead:
			continue
		var target_center: Vector2 = target.call("get_hit_center") if target.has_method("get_hit_center") else target.position
		if body.get_center().distance_to(target_center) <= target.get_hit_radius() + 16.0:
			_player_take_damage()
			return

func _player_take_damage() -> void:
	damage_grace_timer = 1.0
	_player_lose_life("Recibiste daño")

func _player_lose_life(reason: String) -> void:
	if game_finished:
		return
	lives -= 1
	lives = max(lives, 0)
	_lose_all_powers()
	if is_instance_valid(player) and player.has_method("pulse_damage"):
		player.pulse_damage()
	if lives <= 0:
		game_over()
		return
	last_advanced_mechanic = "%s: poderes perdidos" % reason
	start_level(current_level)
	center_message.visible = true
	center_message.text = "PERDISTE UNA VIDA\nPoderes perdidos. Derrota al boss para recuperarlos."
	level_banner_timer = 2.2
	update_hud()

func _check_goal_reached() -> void:
	if lives <= 0 or not boss_defeated or not is_instance_valid(player):
		return
	var feet: Vector2 = player.call("get_feet_position") if player.has_method("get_feet_position") else player.position
	if feet.x >= WORLD_WIDTH - 150.0:
		var state: Node = get_node_or_null("/root/GameState")
		if is_instance_valid(state) and state.has_method("mark_completed"):
			state.call("mark_completed", current_level, score)
		if current_level >= max_level:
			finish_game()
		else:
			start_level(current_level + 1)

func _get_platform_rects() -> Array[Rect2]:
	return [
		Rect2(260, 565, 130, 22),
		Rect2(520, 515, 130, 22),
		Rect2(780, 455, 140, 22),
		Rect2(1060, 540, 130, 22),
		Rect2(1330, 485, 130, 22),
		Rect2(1600, 430, 130, 22),
		Rect2(1880, 540, 140, 22),
		Rect2(2160, 500, 130, 22),
		Rect2(2440, 455, 130, 22)
	]

func _get_enemy_patrols() -> Array[Rect2]:
	return [
		Rect2(330, 650, 190, 0),
		Rect2(620, 650, 230, 0),
		Rect2(980, 650, 220, 0),
		Rect2(1320, 650, 240, 0),
		Rect2(1680, 650, 250, 0),
		Rect2(2080, 650, 250, 0),
		Rect2(2380, 650, 270, 0),
		Rect2(270, 565, 110, 0),
		Rect2(520, 515, 110, 0),
		Rect2(780, 455, 120, 0),
		Rect2(1330, 485, 110, 0),
		Rect2(1880, 540, 120, 0),
		Rect2(2440, 455, 110, 0)
	]

func game_over() -> void:
	game_finished = true
	game_over_return_timer = 2.2
	boss_active = false
	boss_defeated = false
	boss_rays.clear()
	_lose_all_powers()
	_save_current_level_for_map()
	_clear_playfield()
	center_message.visible = true
	center_message.text = "GAME OVER\nVolviendo al mapa de niveles..."
	update_hud()

func _save_current_level_for_map() -> void:
	var state: Node = get_node_or_null("/root/GameState")
	if not is_instance_valid(state):
		return
	state.set("selected_level", clamp(current_level, 1, max_level))
	var unlocked: int = clamp(int(state.get("max_unlocked_level")), 1, max_level)
	state.set("max_unlocked_level", max(unlocked, current_level))

func _return_to_level_map_after_game_over() -> void:
	_save_current_level_for_map()
	get_tree().paused = false
	get_tree().change_scene_to_file(LEVEL_MAP_SCENE_PATH)

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
	if not _has_spread_reward():
		projectile_count = 1
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
	_lose_all_powers()
	boss_rays.clear()
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
	center_message.text = "YOU WIN\nCompletaste InkaRise 8-Bit\nPresiona R para reiniciar"
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
	var shown_cooldown: float = max(cooldown, SPREAD_SHOT_COOLDOWN if _has_spread_reward() else cooldown)
	var active_cooldown_timer: float = max(cooldown_timer, spread_cooldown_timer)
	var cooldown_state: String = "LISTO" if active_cooldown_timer <= 0.0 else "RECARGANDO"
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
			"cooldown": shown_cooldown,
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
			"has_ricochet_power": has_ricochet_power,
			"has_ray_power": has_ray_power,
			"has_homing_power": has_homing_power,
			"is_paused": game_paused
		})
