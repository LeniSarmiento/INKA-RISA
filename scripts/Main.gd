extends Node2D

const BACKGROUND_SCENE := preload("res://scenes/Background.tscn")
const PLAYER_SCENE := preload("res://scenes/Player.tscn")
const PROJECTILE_SCENE := preload("res://scenes/Projectile.tscn")
const TARGET_SCENE := preload("res://scenes/Target.tscn")

var background: Node2D
var player: Node2D
var hud_layer: CanvasLayer
var hud_label: Label
var hud_panel: ColorRect
var center_message: Label
var title_card: TextureRect
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
var lives: int = 5
var spawn_timer: float = 0.0
var spawn_interval: float = 1.30
var max_alive_targets: int = 4
var target_speed: float = 45.0
var target_radius: float = 36.0
var target_hp: int = 1
var game_finished: bool = false

var last_cleaning_note: String = "Parámetros válidos"
var last_runtime_csv_path: String = ""

func _ready() -> void:
	randomize()
	background = BACKGROUND_SCENE.instantiate()
	add_child(background)

	player = PLAYER_SCENE.instantiate()
	player.position = Vector2(180, 615)
	add_child(player)

	_create_hud()
	start_level(1)

func _process(delta: float) -> void:
	if game_finished:
		return
	level_time += delta
	if cooldown_timer > 0.0:
		cooldown_timer -= delta

	var direction := get_global_mouse_position() - player.global_position
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
			KEY_R:
				reset_all_game()
			KEY_L:
				save_runtime_record()
			KEY_N:
				advance_level_for_demo()

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
	center_message.text = "NIVEL %d / 10\nObjetivo: destruye %d fragmentos del Inti" % [current_level, level_goal_hits]
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

	# Parámetros de disparo: se mantienen jugables pero exigen más control en niveles altos.
	projectile_speed = 560.0 + float(level) * 18.0
	cooldown = max(0.20, 0.36 - float(level) * 0.012)
	delta_theta_deg = clamp(8.0 + float(level) * 0.8, 8.0, 18.0)
	projectile_count = 3 if level < 4 else 5
	if level >= 8:
		projectile_count = 7
	sanitize_pattern_params()

func advance_level_for_demo() -> void:
	# Tecla auxiliar para grabar el video demo o probar rápido los 10 niveles.
	if current_level < max_level:
		start_level(current_level + 1)
	else:
		finish_game()

func try_shoot(is_spread: bool) -> void:
	if cooldown_timer > 0.0:
		return
	cooldown_timer = cooldown
	sanitize_pattern_params()
	if is_spread:
		shoot_spread()
	else:
		shoot_projectile(theta_base_rad, "simple")
	update_hud()

func shoot_spread() -> void:
	var center_index := float(projectile_count - 1) / 2.0
	for i in range(projectile_count):
		var offset_deg := (float(i) - center_index) * delta_theta_deg
		var angle := theta_base_rad + deg_to_rad(offset_deg)
		shoot_projectile(angle, "spread")

func shoot_projectile(angle_rad: float, shot_type: String) -> void:
	total_attempts += 1
	level_attempts += 1
	var projectile := PROJECTILE_SCENE.instantiate()
	projectile.global_position = player.get_muzzle_global_position()
	add_child(projectile)
	projectile.setup(angle_rad, projectile_speed, shot_type)
	projectile.projectile_finished.connect(_on_projectile_finished)

func _on_projectile_finished(was_hit: bool, angle_deg: float, shot_type: String) -> void:
	if was_hit:
		# El conteo de impacto final se hace cuando el objetivo queda destruido.
		pass
	else:
		total_misses += 1
		level_misses += 1
	update_hud()

func spawn_one_target() -> void:
	var target := TARGET_SCENE.instantiate()
	var y_min := 150.0
	var y_max := 585.0
	var pos := Vector2(randf_range(980.0, 1320.0), randf_range(y_min, y_max))
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
		lives = 5
		center_message.text = "Reinicio del nivel %d\nSe escaparon demasiados fragmentos" % current_level
		level_banner_timer = 2.5
		start_level(current_level)
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

	var original_count := projectile_count
	projectile_count = clamp(projectile_count, 1, max_projectiles)
	if projectile_count % 2 == 0:
		projectile_count += 1
		if projectile_count > max_projectiles:
			projectile_count -= 2
	if projectile_count != original_count:
		last_cleaning_note += " | Proyectiles ajustados a número impar entre 1 y 9"

func reset_all_game() -> void:
	total_attempts = 0
	total_hits = 0
	total_misses = 0
	score = 0
	lives = 5
	last_cleaning_note = "Juego reiniciado"
	last_runtime_csv_path = ""
	start_level(1)

func finish_game() -> void:
	game_finished = true
	_clear_playfield()
	center_message.visible = true
	center_message.text = "¡GANASTE INKARISE!\nCompletaste los 10 niveles\nPrecisión total: %.1f%%\nPresiona R para reiniciar" % get_total_precision()
	update_hud()

func _clear_playfield() -> void:
	for projectile in get_tree().get_nodes_in_group("projectiles"):
		projectile.queue_free()
	for target in get_tree().get_nodes_in_group("targets"):
		target.queue_free()

func get_total_precision() -> float:
	if total_attempts <= 0:
		return 0.0
	return float(total_hits) * 100.0 / float(total_attempts)

func get_level_precision() -> float:
	if level_attempts <= 0:
		return 0.0
	return float(level_hits) * 100.0 / float(level_attempts)

func save_runtime_record() -> void:
	var path := "user://inka_rise_registro_runtime.csv"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		last_cleaning_note = "No se pudo guardar el registro runtime"
		return
	file.store_line("nivel,theta_base_deg,delta_theta_deg,cantidad_proyectiles,velocidad,cooldown,intentos_nivel,impactos_nivel,fallos_nivel,precision_nivel,intentos_totales,impactos_totales,precision_total,nota_limpieza")
	file.store_line("%d,%.2f,%.2f,%d,%.2f,%.2f,%d,%d,%d,%.2f,%d,%d,%.2f,%s" % [current_level, theta_base_deg, delta_theta_deg, projectile_count, projectile_speed, cooldown, level_attempts, level_hits, level_misses, get_level_precision(), total_attempts, total_hits, get_total_precision(), last_cleaning_note])
	file.close()
	last_runtime_csv_path = ProjectSettings.globalize_path(path)
	last_cleaning_note = "Registro guardado en user://inka_rise_registro_runtime.csv"

func _create_hud() -> void:
	hud_layer = CanvasLayer.new()
	add_child(hud_layer)

	hud_panel = ColorRect.new()
	hud_panel.position = Vector2(12, 12)
	hud_panel.size = Vector2(735, 236)
	hud_panel.color = Color(0.025, 0.02, 0.018, 0.72)
	hud_layer.add_child(hud_panel)

	hud_label = Label.new()
	hud_label.position = Vector2(26, 22)
	hud_label.size = Vector2(705, 224)
	hud_label.add_theme_font_size_override("font_size", 16)
	hud_label.add_theme_color_override("font_color", Color(1.0, 0.94, 0.76))
	hud_layer.add_child(hud_label)

	center_message = Label.new()
	center_message.position = Vector2(350, 260)
	center_message.size = Vector2(580, 150)
	center_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	center_message.add_theme_font_size_override("font_size", 34)
	center_message.add_theme_color_override("font_color", Color(1.0, 0.86, 0.22))
	center_message.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	center_message.add_theme_constant_override("shadow_offset_x", 3)
	center_message.add_theme_constant_override("shadow_offset_y", 3)
	hud_layer.add_child(center_message)

func update_hud() -> void:
	var cooldown_state := "LISTO" if cooldown_timer <= 0.0 else "RECARGANDO"
	hud_label.text = "INKARISE v3 - Disparo trigonométrico + niveles 1 al 10\n"
	hud_label.text += "Nivel: %d/10 | Objetivo: %d/%d | Vidas: %d | Puntaje: %d\n" % [current_level, level_hits, level_goal_hits, lives, score]
	hud_label.text += "θ = %.2f° | Dirección = (cos θ, sin θ) | Estado: %s\n" % [theta_base_deg, cooldown_state]
	hud_label.text += "Controles: Click izq = disparo | Click der = spread | Q/E Δθ | Z/X proyectiles | N nivel demo\n"
	hud_label.text += "Patrón: Δθ = %.1f° | Proyectiles = %d | Velocidad = %.0f px/s | Cooldown = %.2fs\n" % [delta_theta_deg, projectile_count, projectile_speed, cooldown]
	hud_label.text += "Métricas nivel: Intentos = %d | Impactos = %d | Fallos = %d | Precisión = %.1f%%\n" % [level_attempts, level_hits, level_misses, get_level_precision()]
	hud_label.text += "Métricas total: Intentos = %d | Impactos = %d | Precisión = %.1f%%\n" % [total_attempts, total_hits, get_total_precision()]
	hud_label.text += "Limpieza de datos: %s" % last_cleaning_note
	if last_runtime_csv_path != "":
		hud_label.text += "\nCSV runtime: " + last_runtime_csv_path
